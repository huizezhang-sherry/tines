#' Visualize and inspect `tines` objects
#'
#' @description
#' Functions to plot the tines object with Graphviz diagrams. `draw_tines()` and the `plot()` methods render the interactive widget. `inspect_dot()` formats and prints raw DOT strings to the console for debugging.
#'
#' @param x A `schema` or `multiverse` object.
#' @param index An integer. For a `multiverse`, which path index to draw. Defaults to 1.
#' @param dot A character string containing raw Graphviz DOT code.
#' @param indent Integer. The number of spaces to use for each indentation level in `inspect_dot()`. Defaults to 2.
#' @param keep_attr_blocks_one_line Logical. If `TRUE`, attempts to keep square bracket `[]` attribute blocks on a single line.
#' @param trim_trailing_ws Logical. If `TRUE`, trims trailing whitespace from the final output.
#' @param ... Additional arguments passed to methods or to `DiagrammeR::grViz()`.
#'
#' @return
#' `draw_tines()` and `plot()` return an `htmlwidget` object produced by `DiagrammeR::grViz()`. `inspect_dot()` invisibly returns `NULL` and prints to the console.
#'
#' @export
#' @rdname print
#' @examples
#' schema <- example_schema()
#' # plot() and draw_tines() are interchangeable
#' draw_tines(schema)
#' plot(schema)
#' inspect_dot(schema)
#' multiverse <- example_multiverse()
#' draw_tines(multiverse, index = 2)
plot.schema <- function(x, ...) {
  draw_tines(x)
}

#' @export
#' @rdname print
plot.multiverse <- function(x, index = 1, ...) {
  cli::cli_inform("Rendering path {index} of {length(x)}: {.val {names(x)[index]}}")
  draw_tines(x, index = index)
}

#' @export
#' @rdname print
draw_tines <- function(x, index = 1, ...) {

  if (!inherits(x, c("schema", "multiverse"))) {
    cli::cli_abort(c(
      "The object to write must be of class {.cls schema} or {.cls multiverse}.",
      "i" = "Provided object is of class {.cls {class(x)}}."
    ))
  }

  if (inherits(x, "multiverse")) {
    dot_code <- tines2dotspec(x[[index]], ...)
  } else{
    dot_code <- tines2dotspec(x, ...)
  }

  DiagrammeR::grViz(dot_code)
}

tines2dotspec <- function(x, ...) {

  # TODO: not sure how to deal with ... yet


  if (!inherits(x, c("schema", "multiverse"))) {
    cli::cli_abort("Object must be a {.cls schema}")
  }

  # 1. Prepare Node Definitions: use the id as the ID and the action/id as the label
  node_strings <- with(x$nodes, {
    paste0('  "', id, '" [label="', id, '\n(', action, ')", shape=box, style=filled, fillcolor=white]')
  })

  # 2. Prepare Edge Definitions with Semantic Styling
  # TODO: currently only doing sequential edges
  edge_strings <- with(dplyr::filter(x$edges, type == "sequential"), {
    style <- "solid"
    color <- "black"

    paste0('  "', from, '" -> "', to, '" [style=', style, ', color=', color, ']')
  })

  # 3. Assemble the DOT Code
  dot_code <- paste0(
    "digraph schema {\n",
    "  graph [rankdir=TD, fontname=Arial]\n",
    "  node [fontname=Arial, fontsize=10]\n",
    "  edge [fontname=Arial, fontsize=8]\n",
    paste(node_strings, collapse = "\n"), "\n",
    paste(edge_strings, collapse = "\n"), "\n",
    "}"
  )

  return(dot_code)
}

#' @export
#' @rdname print
inspect_dot <- function(dot,
                       indent = 2,
                       keep_attr_blocks_one_line = TRUE,
                       trim_trailing_ws = TRUE) {
  # 1) Unescape literal "\n" sequences if present
  #    (common when DOT is printed as a single R string)
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

    # Increase depth after printing opening braces (but not if it's like "} else {")
    # Simple heuristic: count "{" minus "}" in the line
    opens <- lengths(regmatches(ln, gregexpr("\\{", ln)))
    closes <- lengths(regmatches(ln, gregexpr("\\}", ln)))
    depth <- max(0, depth + opens - closes)

    # If line had a leading "}", we already decreased once; the closes count covers it too,
    # but this is fine because we subtracted then re-applied via counts.
  }

  if (trim_trailing_ws) out <- sub("[ \t]+$", "", out)

  cat(paste(out, collapse = "\n"), "\n")
}



globalVariables("type")
