# Auto-Fix an R Script via Iterative LLM Debugging

Executes an R script in an isolated sandbox. If execution fails, the
error is passed to an LLM (via
[`ellmer::chat()`](https://ellmer.tidyverse.org/reference/chat-any.html))
which attempts to fix the script. This loop repeats up to `max_runs`
times.

## Usage

``` r
validate_script(
  file,
  data = NULL,
  max_runs = 5,
  model = "anthropic/claude-opus-4-5",
  verbose = TRUE,
  as_job = FALSE,
  engine = c("callr", "docker"),
  scan_code = TRUE
)
```

## Arguments

- file:

  Path to the R script to run and debug.

- data:

  Optional path to a CSV data file to make available inside the sandbox
  at `data/<basename>`.

- max_runs:

  Maximum number of LLM fix attempts. Default is `5`.

- model:

  The LLM to use, as a string in `'provider/model'` form (e.g.
  `'anthropic/claude-opus-4-5'`, `'openai/gpt-5'`,
  `'google_gemini/gemini-2.5-flash'`), passed to
  [`ellmer::chat()`](https://ellmer.tidyverse.org/reference/chat-any.html).
  See [`chat`](https://ellmer.tidyverse.org/reference/chat-any.html) for
  the full list of supported providers. Default is
  `'anthropic/claude-opus-4-5'`.

- verbose:

  If `TRUE`, saves a copy of the script at each iteration.

- as_job:

  If `TRUE`, runs the process as a background job. If `FALSE` (default),
  runs in the current R session. Only used when `engine = 'callr'`.

- engine:

  One of `'callr'` (default) or `'docker'`. Controls the execution to be
  with `callr` in a temp directory sandbox (in session or as a
  background job), or within a Docker container.

- scan_code:

  If `TRUE` (default), scans the script for potentially dangerous file
  system commands before execution.

## Value

Invisibly returns a list with:

- success:

  Logical. Whether the script ran without error.

- file:

  Path to the (possibly fixed) script.

- chat_history:

  The `ellmer` chat object with full history.

## Examples

``` r
if (FALSE) { # \dontrun{
validate_script(
  file = here::here("inst/dplyr-filter-equal.R"),
  data = here::here("inst/dplyr-filter-equal.csv")
)
} # }
```
