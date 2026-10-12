#' Visualize and inspect tines objects
#'
#' @description
#' Functions to plot the tines object with Graphviz diagrams. [draw_tines()]
#' and the `plot()` methods render the interactive widget. [inspect_dot()]
#' formats and prints raw DOT strings to the console for debugging.
#'
#' A plain schema is drawn as a chain of steps in order (dashed edges: they
#' record order only). A mapped schema is drawn by data flow: a solid edge
#' runs from the step that creates a variable to each later step that reads
#' it, so steps that share no variables are not joined. A schema whose
#' mapping is incomplete is drawn as a plain one.
#'
#' @param x A `schema` or `multiverse` object, or the path to a YAML file.
#' @param index An integer. For a `multiverse`, which path index to draw.
#'   Defaults to 1.
#' @param schema A `schema` object to convert to DOT code for inspection.
#' @param indent Integer. The number of spaces to use for each indentation
#'   level in [inspect_dot()]. Defaults to 2.
#' @param keep_attr_blocks_one_line Logical. If `TRUE`, attempts to keep
#'   square bracket `[]` attribute blocks on a single line.
#' @param trim_trailing_ws Logical. If `TRUE`, trims trailing whitespace from
#'   the final output.
#' @param ... Additional arguments passed to methods or to
#'   `DiagrammeR::grViz()`.
#'
#' @return
#' [draw_tines()] and `plot()` return an `htmlwidget` object produced by
#' `DiagrammeR::grViz()`. [inspect_dot()] invisibly returns `NULL` and prints
#' to the console.
#'
#' @export
#' @rdname print
#' @examples
#' my_data <- data.frame(age = c(25, 30, 35), income = c(50000, 60000, 70000))
#' schema <- build_schema(data = my_data) |>
#'   add_step(
#'     id = "step-filter", objective = "remove missing values",
#'     decision = "exclude rows with NA",
#'     inputs = c("age", "income"), outputs = "df_clean"
#'   )
#'
#' # plot() and draw_tines() are interchangeable
#' draw_tines(schema)
#' plot(schema)
#' inspect_dot(schema)
#'
#' schema2 <- build_schema(data = my_data) |>
#'   add_step(
#'     id = "step-filter", objective = "remove missing values",
#'     decision = "impute with median",
#'     inputs = c("age", "income"), outputs = "df_clean"
#'   )
#' multiverse <- as_multiverse(list(schema, schema2))
#' draw_tines(multiverse, index = 2)
plot.schema <- function(x, ...) {
  draw_tines(x, ...)
}

#' @export
#' @rdname print
plot.multiverse <- function(x, index = 1, ...) {
  cli::cli_inform(
    "Rendering path {index} of {length(x)}: {.val {names(x)[index]}}"
  )
  draw_tines(x, index = index, ...)
}

#' @export
#' @rdname print
draw_tines <- function(x, index = 1, ...) {
  if (is.character(x) && length(x) == 1) {
    if (!file.exists(x)) cli::cli_abort("File not found: {.val {x}}")
    x <- read_tines(x)
  }

  if (!inherits(x, c("schema", "multiverse"))) {
    cli::cli_abort(c(
      paste0(
        "The object to write must be of class {.cls schema} or ",
        "{.cls multiverse}."
      ),
      "i" = "Provided object is of class {.cls {class(x)}}."
    ))
  }

  if (inherits(x, "multiverse")) {
    schema <- x[[index]]
  } else {
    schema <- x
  }

  check_schema(schema)

  dot_code <- tines2dotspec(schema, ...)

  DiagrammeR::grViz(dot_code)
}

tines2dotspec <- function(x, ...) {
  # TODO: not sure how to deal with ... yet

  if (!inherits(x, c("schema", "multiverse"))) {
    cli::cli_abort("Object must be a {.cls schema}")
  }

  # 1. Prepare Node Definitions: use the id as the ID and the decision/id as
  # the label
  decision <- gsub("\\'", "", x$decision)
  decision <- gsub('\\"', "", decision)
  node_strings <- paste0(
    '  "', x$id, '" [label="', x$id, "\n(", decision, ')", ',
    "shape=box, style=filled, fillcolor=white]"
  )

  # 2. Prepare Edge Definitions: data flow where the schema is mapped, the
  # order of the steps where it is not
  edge_df <- generate_edges(x)

  edge_strings <- if (nrow(edge_df) > 0) {
    paste0(
      '  "', edge_df$from, '" -> "', edge_df$to,
      '" [style=', edge_df$style, ', color=black]'
    )
  } else {
    character(0)
  }

  # 3. Assemble the DOT Code
  dot_code <- paste0(
    "digraph schema {\n",
    "  graph [rankdir=TD, fontname=Arial]\n",
    "  node [fontname=Arial, fontsize=10]\n",
    "  edge [fontname=Arial, fontsize=8]\n",
    paste(node_strings, collapse = "\n"), "\n",
    if (length(edge_strings) > 0) {
      paste(edge_strings, collapse = "\n")
    } else {
      ""
    },
    "\n",
    "}"
  )

  return(dot_code)
}

#' @export
#' @rdname print
inspect_dot <- function(schema,
                        indent = 2,
                        keep_attr_blocks_one_line = TRUE,
                        trim_trailing_ws = TRUE) {
  # 1) Unescape literal "\n" sequences if present
  #    (common when DOT is printed as a single R string)
  dot <- tines2dotspec(schema)
  dot <- gsub("\\\\n", "\n", dot)

  # 2) Normalize line endings
  dot <- gsub("\r\n", "\n", dot)
  dot <- gsub("\r", "\n", dot)

  # 3) Collapse excessive whitespace but preserve inside quotes as best effort
  #    We'll avoid aggressive whitespace collapsing to not break labels.

  # 4) Put braces and semicolons on new lines in a token-friendly way
  #    Add newlines AFTER {, }, ;
  dot2 <- dot
  dot2 <- gsub("\\{", "{\n", dot2)
  dot2 <- gsub("\\}", "\n}\n", dot2)
  dot2 <- gsub(";", ";\n", dot2)

  # 5) Split into lines and clean empties
  lines <- unlist(strsplit(dot2, "\n", fixed = TRUE), use.names = FALSE)
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]

  # 6) Optionally keep attribute blocks on one line:
  #    If we see an opening "[" without a closing "]" on the same line,
  #    keep appending lines until the closing bracket appears.
  if (keep_attr_blocks_one_line) {
    merged <- character(0)
    i <- 1
    while (i <= length(lines)) {
      ln <- lines[i]
      if (grepl("\\[", ln) && !grepl("\\]", ln)) {
        j <- i + 1
        while (j <= length(lines) && !grepl("\\]", lines[j])) {
          ln <- paste(ln, lines[j])
          j <- j + 1
        }
        if (j <= length(lines)) {
          ln <- paste(ln, "\n", lines[j])
          i <- j
        } else {
          i <- j - 1
        }
      }
      merged <- c(merged, ln)
      i <- i + 1
    }
    lines <- merged
  }

  # 7) Indent by brace depth
  out <- character(0)
  depth <- 0

  for (ln in lines) {
    # Decrease depth before printing closing braces
    if (grepl("^\\}", ln)) depth <- max(0, depth - 1)

    pad <- paste(rep(" ", depth * indent), collapse = "")
    out <- c(out, paste0(pad, ln))

    # Increase depth after printing opening braces (but not if it's like
    # "} else {"). Simple heuristic: count "{" minus "}" in the line
    opens <- lengths(regmatches(ln, gregexpr("\\{", ln)))
    closes <- lengths(regmatches(ln, gregexpr("\\}", ln)))
    depth <- max(0, depth + opens - closes)

    # If line had a leading "}", we already decreased once; the closes count
    # covers it too, but this is fine because we subtracted then re-applied
    # via counts.
  }

  if (trim_trailing_ws) out <- sub("[ \t]+$", "", out)

  cat(paste(out, collapse = "\n"), "\n")
}


globalVariables(c("type", "from", "to"))


# Edges for the DOT graph. In a mapped schema a solid edge runs from the step
# that created a variable to each later step that reads it. A plain schema is
# a dashed chain in step order. Called only by tines2dotspec().
generate_edges <- function(schema) {
  empty <- data.frame(from = character(), to = character(), style = character())
  n <- nrow(schema)
  if (n < 2) return(empty)
  ids <- schema$id
  chain <- function(i) data.frame(from = ids[i], to = ids[i + 1], style = "dashed")

  if (!is_mapped(schema)) return(do.call(rbind, lapply(seq_len(n - 1), chain)))

  edges <- list()
  var_sources <- list()
  for (i in seq_len(n)) {
    for (inp in schema$inputs[[i]]) {
      if (inp %in% names(var_sources)) {
        edges[[length(edges) + 1]] <- data.frame(
          from = var_sources[[inp]], to = ids[i], style = "solid"
        )
      }
    }
    for (outp in schema$outputs[[i]]) var_sources[[outp]] <- ids[i]
  }

  if (length(edges) == 0) return(empty)
  dplyr::distinct(do.call(rbind, edges), from, to, .keep_all = TRUE)
}
