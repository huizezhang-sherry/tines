#' Data mapping and validation for schemas
#'
#' @description
#' These functions manage the relationship between a schema and its dataset.
#' Here are the four main scenarios they cover:
#'
#' * Specify the dataset when creating the schema through [build_schema()] and
#'   the inputs/outputs for each step as you add them with [add_step()].
#'
#' * Modify the inputs/outputs for a specific step later with [update_io()].
#'   The function will validate the updated mapping against the attached
#'   dataset (if any).
#'
#' * Provide a new dataset to an existing schema with [update_data()]. The
#'   function will validate the entire schema (inputs/outputs) against the new
#'   dataset.
#'
#' * Combine the update of data and inputs/outputs in one step with
#'   [update_io()] by providing the new dataset using the `data` argument.
#'
#' @param schema A `schema` object
#' @param data A data frame or path to a data file. For `gen_io()` and
#'   `update_data()`, this is required. For `update_io()`, this is optional -
#'   if provided, validates the updated inputs/outputs against this dataset
#'   (without attaching it).
#' @param id Character string identifying which step to update (for
#'   `update_io()`)
#' @param inputs Character vector of input variable names
#' @param outputs Character vector of output variable names
#' @param interactive Logical. If TRUE, prompts user for ambiguous mappings
#' @param model The LLM to use for `gen_io()`, as a string in
#'   `"provider/model"` form (e.g. `"anthropic/claude-opus-4-5"`,
#'   `"openai/gpt-5"`, `"google_gemini/gemini-2.5-flash"`), passed to
#'   `ellmer::chat()`. See [ellmer::chat()] for the full list of supported
#'   providers. Defaults to `"google_gemini/gemini-2.5-flash"`.
#' @param force Logical. If TRUE, remaps even if already mapped
#'
#' @return A `schema` object with updated inputs/outputs and data reference
#'
#' @rdname update-io
#' @export
#' @examples
#' # Create example datasets
#' data_2023 <- data.frame(
#'   age = c(25, 30, 35, NA, 45),
#'   income = c(50000, 60000, NA, 70000, 80000),
#'   city = c("NYC", "LA", "Chicago", "NYC", NA)
#' )
#'
#' data_2024 <- data.frame(
#'   age = c(26, 31, 36, 40, 46),
#'   salary = c(52000, 62000, 68000, 72000, 82000), # Note: 'salary' not 'income'
#'   city = c("NYC", "LA", "Chicago", "Boston", "LA")
#' )
#'
#' # Scenario 1:
#' # specify the dataset when creating the schema through `build_schema()`
#' schema <- build_schema(data = data_2023) |>
#'   add_step(
#'     id = "step-filter", objective = "remove missing values",
#'     decision = "exclude rows with NA",
#'     inputs = c("age", "income"), outputs = "df_clean"
#'   ) |>
#'   add_step(
#'     id = "step-transform", objective = "log transform income",
#'     decision = "use natural log",
#'     inputs = "df_clean", outputs = "df_transformed"
#'   )
#'
#' # Scenario 2:
#' # modify the inputs/outputs with `update_io()`
#' schema_mod <- update_io(schema, "step-filter", inputs = c("age"))
#'
#' # Scenario 3:
#' # provide a new dataset to an existing schema with `update_data()`
#' # The function will trigger validation and return an error when
#' # the mapping is broken (e.g., "income" not found in new dataset)
#' \dontrun{
#' schema <- update_data(schema, data_2024)
#' }
#'
#' # Scenario 4:
#' # combine the update of data and inputs/outputs in one step with `update_io()`
#' # by providing the new dataset using the `data` argument.
#' schema_2024 <- update_io(schema, "step-filter",
#'   inputs = c("age", "salary", "city"),
#'   outputs = "df_clean",
#'   data = data_2024
#' )
#'
#' # LLM approach: auto-infer from dataset (leave untouched)
#' \dontrun{
#' schema_llm <- build_schema() |>
#'   add_step(
#'     id = "step-filter",
#'     objective = "remove missing values",
#'     decision = "exclude rows with NA"
#'   ) |>
#'   add_step(
#'     id = "step-transform",
#'     objective = "log transform income",
#'     decision = "use natural log"
#'   ) |>
#'   gen_io(data = data_2023)
#' }
gen_io <- function(schema, data, interactive = FALSE,
                   model = "google_gemini/gemini-2.5-flash", force = FALSE) {
  # Check if already mapped and data hasn't changed
  if (!force && has_data(schema)) {
    existing_hash <- attr(schema, "data")$hash
    new_hash <- if (is.data.frame(data)) {
      digest::digest(data)
    } else {
      digest::digest(load_data_file(data))
    }

    if (existing_hash == new_hash && is_mapped(schema)) {
      cli::cli_alert_info("Schema already mapped to this dataset. Use {.code force = TRUE} to remap.")
      return(schema)
    }

    if (existing_hash != new_hash) {
      cli::cli_alert_warning("Dataset has changed! Remapping variables...")
    }
  }

  # Create the chat client before doing any data loading work, so an
  # unsupported `model` string fails fast.
  chat <- ellmer::chat(model, echo = "none")

  # Load data if needed
  data_obj <- if (is.data.frame(data)) {
    data
  } else {
    load_data_file(data)
  }

  data_dict <- prepare_data_dict(data_obj)

  cli::cli_alert_info("Using LLM to infer inputs/outputs from dataset...")

  # Build prompt
  prompt <- build_mapping_prompt(schema, data_dict)

  # Call LLM
  yaml_out <- chat$chat(prompt)

  # Parse response
  clean_yaml <- gsub("^```yaml\n|^```\n|```$", "", trimws(yaml_out))
  updated <- yaml::yaml.load(clean_yaml)

  # Update schema with new inputs/outputs
  if (!is.null(updated$nodes)) {
    for (i in seq_len(nrow(schema))) {
      if (i <= length(updated$nodes)) {
        schema$inputs[[i]] <- list(updated$nodes[[i]]$inputs)
        schema$outputs[[i]] <- list(updated$nodes[[i]]$outputs)
      }
    }
  }

  # Attach data reference
  data_source <- if (is.data.frame(data)) deparse(substitute(data)) else data
  attr(schema, "data") <- list(
    source = data_source,
    hash = digest::digest(data_obj),
    dict = data_dict
  )

  cli::cli_alert_success("I/O mapping completed successfully")
  schema
}

#' @rdname update-io
#' @export
update_data <- function(schema, data) {
  # Load data if path provided
  if (is.character(data) && length(data) == 1 && file.exists(data)) {
    data_source <- data
    data_obj <- load_data_file(data)
  } else if (is.data.frame(data)) {
    data_obj <- data
    data_source <- deparse(substitute(data))
  } else {
    cli::cli_abort("{.arg data} must be a data frame or path to a data file")
  }

  # Validate schema against new data
  validation_result <- validate_schema_data(schema, data_obj, return_issues = TRUE)

  if (!validation_result$valid) {
    # Build error message with helpful suggestions
    msg <- c(
      "x" = "Validation failed - data NOT attached",
      " " = "",
      "i" = "Missing variables:"
    )

    for (issue in validation_result$issues) {
      msg <- c(msg, " " = paste0("  Step '", issue$step, "': ", paste(issue$missing, collapse = ", ")))
    }

    msg <- c(
      msg,
      " " = "",
      "i" = paste0(
        "Available in new dataset: ", paste(utils::head(names(data_obj), 10), collapse = ", "),
        if (ncol(data_obj) > 10) "..." else ""
      ),
      " " = "",
      "i" = "Fix options:",
      " " = "  1. Manual fix:         update_io(schema, id, inputs = ..., outputs = ..., data = ...)",
      " " = "  2. Auto-fix with LLM:  gen_io(schema, data, force = TRUE)"
    )

    cli::cli_abort(msg)
  }

  # Attach data
  data_source <- if (is.character(data)) data else deparse(substitute(data))
  attr(schema, "data") <- list(
    source = data_source,
    hash = digest::digest(data_obj),
    dict = prepare_data_dict(data_obj)
  )

  cli::cli_alert_success("Validation passed")
  cli::cli_alert_success("Data attached: {.val {data_source}}")

  schema
}

#' @rdname update-io
#' @export
update_io <- function(schema, id, inputs = NULL, outputs = NULL, data = NULL) {
  idx <- which(schema$id == id)

  if (length(idx) == 0) {
    cli::cli_abort("Step {.val {id}} not found in schema")
  }

  if (!is.null(inputs)) schema$inputs[[idx]] <- list(inputs)
  if (!is.null(outputs)) schema$outputs[[idx]] <- list(outputs)

  # Validate against provided data or attached data
  if (!is.null(data)) {
    # Load data if needed
    data_obj <- if (is.data.frame(data)) {
      data
    } else if (is.character(data) && file.exists(data)) {
      load_data_file(data)
    } else {
      cli::cli_abort("{.arg data} must be a data frame or path to a data file")
    }

    data_dict <- prepare_data_dict(data_obj)
    validate_step_variables(schema, idx, data_dict)
  } else if (has_data(schema)) {
    # Validate against attached data
    data_dict <- attr(schema, "data")$dict
    validate_step_variables(schema, idx, data_dict)
  }

  schema
}

#' @keywords internal
ensure_mapped <- function(schema, data = NULL, operation = "this operation") {
  # Check if schema has inputs/outputs
  mapped <- is_mapped(schema)

  if (mapped) {
    # Check if data has changed
    if (!is.null(data) && has_data(schema)) {
      new_hash <- if (is.data.frame(data)) {
        digest::digest(data)
      } else {
        digest::digest(load_data_file(data))
      }

      existing_hash <- attr(schema, "data")$hash

      if (existing_hash != new_hash) {
        cli::cli_alert_warning(c(
          "!" = "Dataset has changed since last mapping!",
          "i" = "Remapping variables to new dataset..."
        ))
        return(gen_io(schema, data, force = TRUE))
      }
    }
    return(schema)
  }

  # Schema is unmapped - need to map
  if (is.null(data)) {
    # Check if data is attached to schema
    if (has_data(schema)) {
      data_source <- attr(schema, "data")$source
      cli::cli_alert_info("Using attached data: {.val {data_source}}")
      data <- load_data_file(data_source)
      return(gen_io(schema, data))
    }

    cli::cli_abort(c(
      "x" = "{operation} requires inputs/outputs but schema is unmapped.",
      "i" = "Either provide {.arg data} argument or manually specify inputs/outputs using {.fn update_io}."
    ))
  }

  # Map using provided data
  gen_io(schema, data)
}

# ============================================================================
# Helper functions
# ============================================================================

#' @keywords internal
is_mapped <- function(schema) {
  # A schema is considered mapped if at least one step has non-NA inputs or outputs
  has_inputs <- any(!is.na(unlist(schema$inputs)))
  has_outputs <- any(!is.na(unlist(schema$outputs)))
  has_inputs || has_outputs
}

#' @keywords internal
has_data <- function(schema) {
  !is.null(attr(schema, "data"))
}

#' @keywords internal
prepare_data_dict <- function(data) {
  if (is.data.frame(data)) {
    # Create simple name -> type dictionary
    dict <- data.frame(
      name = names(data),
      type = sapply(data, function(x) class(x)[1]),
      stringsAsFactors = FALSE
    )
    return(dict)
  }

  if (is.character(data)) {
    return(data.frame(name = data, stringsAsFactors = FALSE))
  }

  stop("data_dict must be a data frame or character vector")
}

#' @keywords internal
load_data_file <- function(path) {
  if (!file.exists(path)) {
    cli::cli_abort("Data file not found: {.path {path}}")
  }

  ext <- tools::file_ext(path)

  data <- switch(tolower(ext),
    csv = readr::read_csv(path, show_col_types = FALSE),
    rds = readRDS(path),
    rda = ,
    rdata = {
      env <- new.env()
      load(path, envir = env)
      env[[ls(env)[1]]]
    },
    cli::cli_abort("Unsupported file format: {.val {ext}}")
  )

  data
}

#' @keywords internal
validate_schema_data <- function(schema, data, return_issues = FALSE) {
  if (!is_mapped(schema)) {
    # No validation needed for unmapped schema
    if (return_issues) {
      return(list(valid = TRUE, issues = list()))
    }
    return(invisible(TRUE))
  }

  # Build list of available variables as we walk through the schema
  # Start with columns from the original dataset
  available_vars <- names(data)

  issues <- list()

  # Walk through schema in order
  for (i in seq_len(nrow(schema))) {
    step_id <- schema$id[i]
    step_inputs <- unlist(schema$inputs[[i]])
    step_outputs <- unlist(schema$outputs[[i]])

    # Remove NA values
    step_inputs <- step_inputs[!is.na(step_inputs)]
    step_outputs <- step_outputs[!is.na(step_outputs)]

    # Check if inputs are available (either from data or created by previous steps)
    if (length(step_inputs) > 0) {
      missing <- setdiff(step_inputs, available_vars)

      if (length(missing) > 0) {
        issues[[length(issues) + 1]] <- list(
          step = step_id,
          missing = missing
        )
      }
    }

    # Add this step's outputs to available variables for subsequent steps
    if (length(step_outputs) > 0) {
      available_vars <- c(available_vars, step_outputs)
    }
  }

  # Return issues if requested
  if (return_issues) {
    return(list(
      valid = length(issues) == 0,
      issues = issues
    ))
  }

  # Report issues if any
  if (length(issues) > 0) {
    for (issue in issues) {
      cli::cli_warn(c(
        "!" = "Step {.val {issue$step}} references unavailable variables:",
        "x" = "{.var {issue$missing}}",
        "i" = "These are not in the dataset or created by previous steps"
      ))
    }
    return(invisible(FALSE))
  }

  invisible(TRUE)
}

#' @keywords internal
validate_step_variables <- function(schema, step_idx, data_dict) {
  # Build available variables by walking through schema up to this point
  available_vars <- data_dict$name

  # Add outputs from all previous steps
  if (step_idx > 1) {
    for (i in seq_len(step_idx - 1)) {
      prev_outputs <- unlist(schema$outputs[[i]])
      prev_outputs <- prev_outputs[!is.na(prev_outputs)]
      available_vars <- c(available_vars, prev_outputs)
    }
  }

  # Check if this step's inputs are available
  inputs <- unlist(schema$inputs[[step_idx]])
  inputs <- inputs[!is.na(inputs)]

  if (length(inputs) == 0) {
    return(invisible(TRUE))
  }

  missing <- setdiff(inputs, available_vars)

  if (length(missing) > 0) {
    cli::cli_warn(c(
      "!" = "Step {.val {schema$id[step_idx]}} references unavailable variables:",
      "x" = "{.var {missing}}",
      "i" = "These are not in the dataset or created by previous steps"
    ))
    return(invisible(FALSE))
  }

  invisible(TRUE)
}

#' @keywords internal
build_mapping_prompt <- function(schema, data_dict) {
  col_info <- if (is.data.frame(data_dict) && "type" %in% names(data_dict)) {
    paste0(data_dict$name, " (", data_dict$type, ")", collapse = ", ")
  } else if (is.data.frame(data_dict)) {
    paste0(data_dict$name, collapse = ", ")
  } else {
    paste0(data_dict, collapse = ", ")
  }

  paste0(
    "You are mapping an analysis schema to a specific dataset.\n\n",
    "=== TASK ===\n\n",
    "For each step in the schema, identify:\n",
    "1. **inputs**: Which existing columns from the dataset are needed\n",
    "2. **outputs**: Which new variables/objects this step creates\n\n",
    "=== RULES ===\n\n",
    "1. Inputs must be actual column names from the dataset (or outputs from previous steps)\n",
    "2. Outputs are new variables being created, use snake_case naming\n",
    "3. If a step doesn't need inputs (e.g., initial data load), use empty array []\n",
    "4. Be specific - match variable names to the step's objective and decision\n",
    "5. Preserve the chronological order of steps\n\n",
    "=== DATASET COLUMNS ===\n\n",
    col_info, "\n\n",
    "=== SCHEMA ===\n\n",
    yaml::as.yaml(schema), "\n\n",
    "=== OUTPUT FORMAT ===\n\n",
    "Return ONLY valid YAML with this structure (no markdown formatting):\n\n",
    "nodes:\n",
    "- id: step-1\n",
    "  inputs: [col1, col2]\n",
    "  outputs: [new_var]\n",
    "- id: step-2\n",
    "  inputs: [new_var, col3]\n",
    "  outputs: [result]\n"
  )
}
