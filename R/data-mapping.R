#' Map a schema to data
#'
#' @description
#' A schema's four core fields describe an analysis without reference to any
#' dataset. It can also carry a reference to the data it runs on, and be
#' *mapped*: every step given the variables it reads (`inputs`) and creates
#' (`outputs`). Mapping is optional -- [gen_code()] works on a schema without
#' it. A mapped schema can be checked against its data before any code is
#' generated, constrains the variable names the generated code uses, and lets
#' [draw_tines()] draw data-flow edges.
#'
#' A schema is in one of three states, and the state belongs to the whole
#' schema, never to one step:
#'
#' * **plain** -- no step has inputs/outputs;
#' * **incomplete** -- some steps do. What has been written is kept (and
#'   written to file), but nothing relies on it: it is not checked, not drawn
#'   and not given to [gen_code()]. A message names the steps still missing;
#' * **mapped** -- every step has both.
#'
#' The functions:
#'
#' * [update_data()] sets the data reference: a data file, a
#'   `"package::dataset"` string, an R script that builds the data, or a data
#'   frame.
#' * [gen_io()] drafts the inputs/outputs of every step with an LLM, for you
#'   to review. It is never called implicitly. This is the recommended way
#'   to map a schema: inputs and outputs written by hand are easy to get
#'   wrong, so a hand-written schema is best left unmapped.
#' * [update_io()] sets the inputs/outputs of one step, to correct a drafted
#'   mapping. [add_step()] takes the same `inputs`/`outputs` arguments, and
#'   they can be written in the YAML file.
#'
#' Every one of these re-checks the schema with [validate_schema()] and
#' warns about any problem the change introduced, so a broken mapping is
#' caught when it is made. See the "Mapping a schema to data" section of
#' `vignette("schema")` for an overview.
#'
#' @param schema A `schema` object.
#' @param data The data the schema runs on: a path to a data file (`.csv`,
#'   `.rds`, `.rda`), a `"package::dataset"` string, a path to an R script
#'   that creates the data, or a data frame. Only the column names and types
#'   are kept; the data itself is never stored on the schema. A data frame
#'   gives no reference that can be written to a file, so it is used for
#'   checking only.
#' @param object For an R script, the name of the object the script creates
#'   that holds the data. If `NULL`, the script must create exactly one data
#'   frame.
#' @param id The id of the step to update.
#' @param inputs,outputs Character vectors of variable names; `character(0)`
#'   records that the step has none. `NULL` leaves the field unchanged, and
#'   `NA` clears it.
#' @param model The LLM to use for [gen_io()], as a string in
#'   `"provider/model"` form (e.g. `"anthropic/claude-opus-4-5"`,
#'   `"openai/gpt-5"`, `"google_gemini/gemini-2.5-flash"`), passed to
#'   [ellmer::chat()]. Defaults to `"anthropic/claude-opus-4-5"`.
#'
#' @return A `schema` object.
#'
#' @seealso [validate_schema()] for what the checks cover.
#' @rdname data-mapping
#' @export
#' @examples
#' hdi_data <- data.frame(
#'   life_exp = c(72, 81, 66),
#'   exp_sch = c(13, 16, 10),
#'   gni = c(9000, 42000, 3200)
#' )
#'
#' # map each step by hand as you add it
#' schema <- build_schema("HDI", data = hdi_data) |>
#'   add_step(
#'     id = "step-scaling", decision = "apply min-max scaling",
#'     inputs = c("life_exp", "exp_sch", "gni"), outputs = "scaled"
#'   ) |>
#'   add_step(
#'     id = "step-combine", decision = "use the geometric mean",
#'     inputs = "scaled", outputs = "hdi"
#'   )
#'
#' # map a plain schema by hand, one step at a time
#' plain <- example_hdi() |>
#'   update_io("step-scaling", inputs = c("life_exp", "exp_sch"), outputs = "scaled")
#'
#' # edit one step: renaming an output flags the step that still reads it
#' schema <- update_io(schema, "step-scaling", outputs = "df_scaled")
#'
#' # ...and fixed
#' schema <- update_io(schema, "step-combine", inputs = "df_scaled")
#'
#' # point the schema at a dataset whose columns no longer match
#' renamed <- data.frame(life_exp = 70, exp_sch = 12, income = 8000)
#' schema <- update_data(schema, renamed)
#'
#' \dontrun{
#' # Requires an LLM API key (e.g. ANTHROPIC_API_KEY); not run automatically.
#' example_hdi() |>
#'   gen_io(data = hdi_data)
#' }
update_data <- function(schema, data, object = NULL) {
  check_is_schema(schema)
  baseline <- schema_issues(schema)
  attr(schema, "data") <- data_ref(data, object = object)
  check_schema(schema, baseline = baseline)
}

#' @rdname data-mapping
#' @export
update_io <- function(schema, id, inputs = NULL, outputs = NULL) {
  check_is_schema(schema)
  idx <- which(schema$id == id)
  if (length(idx) == 0) {
    cli::cli_abort("Step {.val {id}} not found in schema.")
  }

  baseline <- schema_issues(schema)
  schema <- add_io_columns(schema)
  if (!is.null(inputs)) schema <- set_step_io(schema, idx, "inputs", inputs)
  if (!is.null(outputs)) schema <- set_step_io(schema, idx, "outputs", outputs)

  check_schema(schema, baseline = baseline)
}

#' @rdname data-mapping
#' @export
gen_io <- function(schema, data = NULL, object = NULL,
                   model = "anthropic/claude-opus-4-5") {
  check_is_schema(schema)
  if (!is.null(data)) {
    ref <- data_ref(data, object = object)
  } else if (has_data(schema)) {
    ref <- attr(schema, "data", exact = TRUE)
    # Calling gen_io() is an explicit request, so a script source is run
    # without asking.
    if (is.null(ref$columns)) ref$columns <- source_columns(ref$source, ref$object)
  } else {
    cli::cli_abort(c(
      "{.fn gen_io} needs the data's columns to map against.",
      "i" = "Supply {.arg data}, or attach it first with {.fn update_data}."
    ))
  }

  # Create the chat client before doing any other work, so an unsupported
  # `model` string fails fast.
  chat <- ellmer::chat(model, echo = "none")

  cli::cli_alert_info("Using an LLM to draft inputs/outputs from the data's columns...")
  yaml_out <- chat$chat(build_mapping_prompt(schema, ref$columns))
  clean_yaml <- gsub("^```yaml\n|^```\n|```$", "", trimws(yaml_out))
  mapped <- yaml::yaml.load(clean_yaml)$nodes

  # Match the reply to steps by id rather than by position, so a reply that
  # reorders steps cannot shift every mapping after it. A step the reply
  # leaves out is left without inputs/outputs, which the check reports.
  reply_ids <- purrr::map_chr(mapped, function(n) as.character(n$id %||% NA))
  nodes <- mapped[match(schema$id, reply_ids)]
  keep <- schema_attrs(schema)
  from_reply <- function(n, field) {
    if (is.null(n)) NA_character_ else as_io(n[[field]] %||% character(0))
  }
  schema$inputs <- lapply(nodes, from_reply, field = "inputs")
  schema$outputs <- lapply(nodes, from_reply, field = "outputs")
  keep$data <- ref
  schema <- restore_schema(schema, keep)

  cli::cli_alert_success("Drafted inputs/outputs -- review them before relying on them.")
  check_schema(schema)
}

#' Check a schema
#'
#' @description
#' Checks a schema's structure and, if it is mapped, its inputs and outputs.
#' Every function that builds or changes a schema -- [build_schema()],
#' [add_step()], [update_io()], [update_data()], [read_tines()],
#' [as_schema()], [expand_tines()] -- runs these checks and reports the
#' problems its change introduced; [gen_code()] and [draw_tines()] run them
#' before using a schema. Call [validate_schema()] yourself after editing a
#' schema directly, e.g. with `schema$inputs[[2]] <- ...`.
#'
#' **Structure** (an error): the `id`, `objective`, `decision` and
#' `rationale` fields exist, and ids are present and unique.
#'
#' **Completeness** (a message): if some steps have inputs/outputs but not
#' all, the mapping is incomplete. It is kept, but the checks below wait
#' until every step has both.
#'
#' **Inputs and outputs** (a warning), for a mapped schema, walking the steps
#' in order:
#'
#' * no two steps create the same output;
#' * no step reads a variable that only a later step creates;
#' * if the data's columns are known, every input is either a column or the
#'   output of an earlier step.
#'
#' @param x A `schema` object.
#' @return `x`, invisibly.
#' @seealso [update_io()] and [update_data()] to fix what it reports, and
#'   [validate_script()] to check the generated code by running it.
#' @export
#' @examples
#' schema <- build_schema(data = data.frame(x = 1:3)) |>
#'   add_step(id = "a", decision = "d", inputs = "x", outputs = "y") |>
#'   add_step(id = "b", decision = "d", inputs = "y", outputs = "z")
#'
#' # an edit made directly on the tibble skips the checks...
#' schema$inputs[[2]] <- "w"
#'
#' # ...so run them yourself
#' validate_schema(schema)
validate_schema <- function(x) {
  check_is_schema(x)
  invisible(check_schema(x, notes = TRUE))
}

# ============================================================================
# The checks
# ============================================================================

# Runs the structural checks (which abort) and the I/O checks (which warn),
# and returns `x` -- visibly, since every constructor ends with it. `baseline`
# is the issue list of the schema as it was before a change; issues already
# present in it are not reported again, so a pipe of add_step() calls reports
# each problem once, not once per step.
# Notes (e.g. that no columns are known) are shown only on request; `info`
# (an incomplete mapping, or one just completed) can be switched off by a
# caller that summarises it itself.
check_schema <- function(x, baseline = NULL, notes = FALSE, info = TRUE) {
  check_schema_structure(x)
  issues <- schema_issues(x)
  if (!is.null(baseline)) {
    if (info && is_mapped(x) && any(startsWith(baseline$key, "incomplete"))) {
      cli::cli_alert_success("Every step now has inputs/outputs, so the mapping is checked and used.")
    }
    issues <- issues[!issues$key %in% baseline$key, ]
  }
  report_issues(issues, notes = notes, info = info)
  x
}

check_schema_structure <- function(x) {
  required <- c("id", "objective", "decision", "rationale")
  missing_cols <- setdiff(required, names(x))
  if (length(missing_cols) > 0) {
    cli::cli_abort(
      "A schema needs the field{?s} {.field {missing_cols}}.",
      call = NULL
    )
  }
  if (anyNA(x$id) || any(!nzchar(x$id))) {
    cli::cli_abort("Every step needs an {.field id}.", call = NULL)
  }
  dup <- unique(x$id[duplicated(x$id)])
  if (length(dup) > 0) {
    cli::cli_abort("Step id{?s} {.val {dup}} {?is/are} used more than once.", call = NULL)
  }
  cols <- c("inputs", "outputs") %in% names(x)
  if (any(cols) && !all(cols)) {
    cli::cli_abort(
      "A schema with inputs/outputs needs both an {.field inputs} and an {.field outputs} column.",
      call = NULL
    )
  }
  if (has_io(x)) {
    ok <- function(v) io_missing(v) || is.character(v)
    if (!all(vapply(c(x$inputs, x$outputs), ok, logical(1)))) {
      cli::cli_abort(
        "{.field inputs} and {.field outputs} must hold character vectors of variable names.",
        call = NULL
      )
    }
  }
  invisible(x)
}

# One row per issue: `key` identifies it across versions of a schema (for
# the baseline comparison), `severity` is "warning", "info" or "note".
schema_issues <- function(x) {
  empty <- data.frame(key = character(), severity = character(), message = character())
  issue <- function(key, severity, message) {
    data.frame(key = key, severity = severity, message = message)
  }

  # An incomplete mapping is reported, and nothing more: until every step has
  # inputs/outputs, none of them is relied on, so none is checked. Keyed by
  # the missing steps, so the message changes as they are filled in.
  missing <- unmapped_steps(x)
  if (length(missing) > 0) {
    n <- length(missing)
    which <- sprintf(
      if (n == 1) "step %s has" else "steps %s have",
      paste0("`", missing, "`", collapse = ", ")
    )
    return(issue(
      paste("incomplete", paste(sort(missing), collapse = " ")), "info",
      sprintf(
        "The mapping is incomplete: %s no inputs/outputs yet (%d of %d steps mapped). Until every step has them, they are kept but not checked or used.",
        which, nrow(x) - n, nrow(x)
      )
    ))
  }
  if (!is_mapped(x) || nrow(x) == 0) return(empty)

  out <- list()
  ids <- x$id
  cols <- attr(x, "data", exact = TRUE)$columns$name

  # Each output should be created once
  owners <- list()
  for (i in seq_along(ids)) {
    for (v in x$outputs[[i]]) owners[[v]] <- c(owners[[v]], ids[i])
  }
  for (v in names(owners)) {
    if (length(owners[[v]]) > 1) {
      out[[length(out) + 1]] <- issue(
        paste("dup-output", v), "warning",
        sprintf("`%s` is created by more than one step: %s.", v,
                paste(owners[[v]], collapse = ", "))
      )
    }
  }

  # Walk the steps in order, tracking what is available at each point
  produced <- character()
  for (i in seq_along(ids)) {
    later <- if (i < length(ids)) seq(i + 1, length(ids)) else integer()
    for (v in setdiff(x$inputs[[i]], c(produced, cols))) {
      creator <- later[vapply(later, function(j) v %in% x$outputs[[j]], logical(1))]
      if (length(creator) > 0) {
        out[[length(out) + 1]] <- issue(
          paste("read-before-created", ids[i], v), "warning",
          sprintf("Step `%s` reads `%s`, which is only created later, by `%s`.",
                  ids[i], v, ids[creator[1]])
        )
      } else if (!is.null(cols)) {
        out[[length(out) + 1]] <- issue(
          paste("not-found", ids[i], v), "warning",
          sprintf("Step `%s` reads `%s`, which is neither a data column nor created by an earlier step.",
                  ids[i], v)
        )
      }
    }
    produced <- c(produced, x$outputs[[i]])
  }

  if (is.null(cols)) {
    out[[length(out) + 1]] <- issue(
      "no-columns", "note",
      "The data's columns are not known, so inputs were checked only against other steps' outputs."
    )
  }

  if (length(out) == 0) return(empty)
  do.call(rbind, out)
}

report_issues <- function(issues, notes = FALSE, info = TRUE) {
  warnings <- issues$message[issues$severity == "warning"]
  if (length(warnings) > 0) {
    cli::cli_warn(
      c("The schema's inputs/outputs have {length(warnings)} problem{?s}:",
        stats::setNames(warnings, rep("!", length(warnings)))),
      call = NULL
    )
  }
  if (info) {
    msgs <- issues$message[issues$severity == "info"]
    if (length(msgs) > 0) cli::cli_inform(stats::setNames(msgs, rep("i", length(msgs))))
  }
  if (notes) {
    msgs <- issues$message[issues$severity == "note"]
    if (length(msgs) > 0) cli::cli_inform(stats::setNames(msgs, rep("i", length(msgs))))
    if (nrow(issues) == 0) {
      cli::cli_alert_success("No problems found.")
    }
  }
  invisible(issues)
}

# ============================================================================
# Inputs/outputs representation
# ============================================================================
#
# A schema with inputs/outputs has both columns, as list-columns holding one
# character vector per step (`character(0)` when the step has none). A step
# not yet given its inputs/outputs holds NA. The state is judged for the
# whole schema: plain (no columns), incomplete (some NA), or mapped (none).

has_io <- function(schema) {
  all(c("inputs", "outputs") %in% names(schema))
}

io_missing <- function(v) is.null(v) || (length(v) == 1 && is.na(v))

# Steps without inputs or outputs, in a schema that has I/O columns
unmapped_steps <- function(schema) {
  if (!has_io(schema)) return(character())
  gaps <- vapply(seq_len(nrow(schema)), function(i) {
    io_missing(schema$inputs[[i]]) || io_missing(schema$outputs[[i]])
  }, logical(1))
  schema$id[gaps]
}

is_mapped <- function(schema) {
  has_io(schema) && length(unmapped_steps(schema)) == 0
}

has_data <- function(schema) {
  !is.null(attr(schema, "data", exact = TRUE))
}

# Coerce whatever a caller or a YAML file supplies into a character vector,
# or NA for "not given".
as_io <- function(v) {
  if (is.null(v)) return(NA_character_)
  if (is.list(v)) v <- unlist(v, use.names = FALSE)
  if (length(v) == 0) return(character(0))
  if (all(is.na(v))) return(NA_character_)
  as.character(v)
}

add_io_columns <- function(schema) {
  if (has_io(schema)) return(schema)
  keep <- schema_attrs(schema)
  unset <- rep(list(NA_character_), nrow(schema))
  schema$inputs <- unset
  schema$outputs <- unset
  restore_schema(schema, keep)
}

drop_io_columns <- function(schema) {
  keep <- schema_attrs(schema)
  schema$inputs <- NULL
  schema$outputs <- NULL
  restore_schema(schema, keep)
}

set_step_io <- function(schema, idx, field, value) {
  keep <- schema_attrs(schema)
  schema[[field]][idx] <- list(as_io(value))
  restore_schema(schema, keep)
}

# The attributes a schema carries beyond a tibble's; `[`, `$<-` and
# bind_rows() may drop them, so they are saved and put back around edits.
schema_attrs <- function(x) {
  list(name = attr(x, "name", exact = TRUE), data = attr(x, "data", exact = TRUE))
}

restore_schema <- function(x, attrs) {
  class(x) <- c("schema", "tbl_df", "tbl", "data.frame")
  attr(x, "name") <- attrs$name
  attr(x, "data") <- attrs$data
  x
}

check_is_schema <- function(x) {
  if (!inherits(x, "schema")) {
    cli::cli_abort("Expected a {.cls schema}, not {.cls {class(x)}}.", call = NULL)
  }
  invisible(x)
}

# ============================================================================
# The data reference
# ============================================================================
#
# attr(schema, "data") is list(source, object, columns):
#   source  -- a file path, "package::dataset", or script path; NULL for a
#              data frame, which leaves nothing that can be written down
#   object  -- for a script, the object holding the data
#   columns -- data.frame(name, type), or NULL if not (yet) looked up
# The data itself is never kept.

data_ref <- function(data, object = NULL, columns = TRUE) {
  if (is.data.frame(data)) {
    return(list(source = NULL, object = NULL, columns = prepare_data_dict(data)))
  }
  if (!is.character(data) || length(data) != 1) {
    cli::cli_abort(
      "{.arg data} must be a data frame, a file path, or a {.val package::dataset} string.",
      call = NULL
    )
  }
  list(
    source = data,
    object = object,
    columns = if (columns) source_columns(data, object) else NULL
  )
}

source_kind <- function(source) {
  if (grepl("^[A-Za-z][A-Za-z0-9.]*::[A-Za-z0-9._]+$", source) && !file.exists(source)) {
    return("package")
  }
  if (tolower(tools::file_ext(source)) == "r") return("script")
  "file"
}

# Look up a source's column names and types without keeping the data.
source_columns <- function(source, object = NULL) {
  kind <- source_kind(source)

  if (kind == "package") {
    pkg <- sub("::.*", "", source)
    name <- sub(".*::", "", source)
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cli::cli_abort("Package {.pkg {pkg}} is needed for data {.val {source}}.", call = NULL)
    }
    env <- new.env()
    found <- tryCatch({
      utils::data(list = name, package = pkg, envir = env)
      exists(name, envir = env, inherits = FALSE)
    }, warning = function(w) FALSE)
    obj <- if (found) get(name, envir = env) else getExportedValue(pkg, name)
    return(prepare_data_dict(obj))
  }

  if (!file.exists(source)) {
    cli::cli_abort("Data file not found: {.path {source}}", call = NULL)
  }

  if (kind == "script") {
    return(callr::r(
      function(path, object) {
        env <- new.env()
        sys.source(path, envir = env)
        if (is.null(object)) {
          is_df <- vapply(ls(env), function(n) is.data.frame(get(n, env)), logical(1))
          if (sum(is_df) != 1) {
            stop(
              "The script creates ", sum(is_df), " data frames; ",
              "name the one holding the data with `object`.",
              call. = FALSE
            )
          }
          object <- ls(env)[is_df]
        }
        obj <- get(object, envir = env)
        data.frame(
          name = names(obj),
          type = unname(vapply(obj, function(x) class(x)[1], "")),
          row.names = NULL
        )
      },
      args = list(normalizePath(source), object)
    ))
  }

  ext <- tolower(tools::file_ext(source))
  switch(ext,
    csv = {
      # spec_csv() guesses types from a sample of rows; the data is not kept.
      spec <- readr::spec_csv(source)
      type <- unname(vapply(spec$cols, function(c) sub("^collector_", "", class(c)[1]), ""))
      # Name types the way class() does for a data frame read into R
      type[type == "double"] <- "numeric"
      data.frame(name = names(spec$cols), type = type)
    },
    rds = prepare_data_dict(readRDS(source)),
    rda = ,
    rdata = {
      env <- new.env()
      load(source, envir = env)
      prepare_data_dict(get(object %||% ls(env)[1], envir = env))
    },
    cli::cli_abort("Unsupported data file format: {.val {ext}}", call = NULL)
  )
}

# Fill in a data reference's columns on read. A script is someone else's code
# as far as read_tines() knows, so it is run only with permission: `validate`
# is "ask" (ask in an interactive session, skip otherwise), "always" or
# "never".
resolve_columns <- function(ref, validate) {
  if (is.null(ref$source) || !is.null(ref$columns) || validate == "never") return(ref)
  kind <- source_kind(ref$source)

  if (kind != "package" && !file.exists(ref$source)) {
    cli::cli_warn(
      "Data file not found: {.path {ref$source}}. The schema was not checked against it.",
      call = NULL
    )
    return(ref)
  }

  if (kind == "script" && validate == "ask") {
    if (!is_interactive()) {
      cli::cli_inform(c(
        "i" = "The data comes from a script, {.path {ref$source}}, which was not run.",
        " " = "Use {.code read_tines(validate = \"always\")} to run it and check the schema."
      ))
      return(ref)
    }
    if (!isTRUE(ask_run_script(ref$source))) {
      cli::cli_inform("The schema was not checked against its data.")
      return(ref)
    }
  }

  ref$columns <- source_columns(ref$source, ref$object)
  ref
}

# Wrapped so tests can stand in for the user's answer.
is_interactive <- function() interactive()

ask_run_script <- function(source) {
  cli::cli_inform("The schema's data comes from a script: {.path {source}}")
  utils::askYesNo("Run it to check the schema's inputs against the data?")
}

prepare_data_dict <- function(data) {
  if (!is.data.frame(data)) {
    cli::cli_abort("The data must be a data frame.", call = NULL)
  }
  data.frame(
    name = names(data),
    type = unname(vapply(data, function(x) class(x)[1], character(1))),
    row.names = NULL
  )
}

# ============================================================================
# Paths
# ============================================================================
#
# A file's `meta.data.source` is relative to the file itself, so a schema and
# its data can be moved or shared together. In R, a source is relative to the
# working directory, like any other path.

is_absolute_path <- function(path) grepl("^(/|~|[A-Za-z]:[/\\\\])", path)

normalize_path <- function(path) {
  if (file.exists(path)) return(normalizePath(path, winslash = "/"))
  file.path(normalizePath(dirname(path), winslash = "/", mustWork = FALSE), basename(path))
}

path_rel <- function(path, start = getwd()) {
  p <- strsplit(normalize_path(path), "/", fixed = TRUE)[[1]]
  s <- strsplit(normalizePath(start, winslash = "/", mustWork = FALSE), "/", fixed = TRUE)[[1]]
  n <- 0
  while (n < min(length(p), length(s)) && p[n + 1] == s[n + 1]) n <- n + 1
  # Nothing in common beyond the root (e.g. another drive): stay absolute
  if (n <= 1) return(normalize_path(path))
  rel <- c(rep("..", length(s) - n), p[-seq_len(n)])
  if (length(rel) == 0) "." else paste(rel, collapse = "/")
}

# `source` as written in the file at `file_path` -> relative to the working
# directory.
source_from_file <- function(source, file_path) {
  if (source_kind(source) == "package" || is_absolute_path(source)) return(source)
  path_rel(file.path(dirname(file_path), source))
}

# `source` relative to the working directory -> relative to the file being
# written at `file_path`.
source_for_file <- function(source, file_path) {
  if (source_kind(source) == "package") return(source)
  path_rel(source, start = dirname(normalize_path(file_path)))
}

`%||%` <- function(x, y) if (is.null(x)) y else x

# ============================================================================
# LLM prompt
# ============================================================================

build_mapping_prompt <- function(schema, columns) {
  col_info <- if ("type" %in% names(columns)) {
    paste0(columns$name, " (", columns$type, ")", collapse = ", ")
  } else {
    paste0(columns$name, collapse = ", ")
  }
  steps <- as.data.frame(schema)[c("id", "objective", "decision", "rationale")]

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
    "5. Return every step, keyed by its id, in the schema's order\n\n",
    "=== DATASET COLUMNS ===\n\n",
    col_info, "\n\n",
    "=== SCHEMA ===\n\n",
    yaml::as.yaml(steps, column.major = FALSE), "\n\n",
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
