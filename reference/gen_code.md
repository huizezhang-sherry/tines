# Generate R code from a schema or multiverse

Generate R code from a schema or multiverse

## Usage

``` r
gen_code(
  x,
  base_code = NULL,
  data = NULL,
  output = "scripts",
  model = "anthropic/claude-opus-4-5",
  ...
)

# S3 method for class 'character'
gen_code(
  x,
  base_code = NULL,
  data = NULL,
  output = "scripts",
  model = "anthropic/claude-opus-4-5",
  ...
)

# S3 method for class 'schema'
gen_code(
  x,
  base_code = NULL,
  data = NULL,
  output = "scripts",
  model = "anthropic/claude-opus-4-5",
  ...
)

# S3 method for class 'multiverse'
gen_code(
  x,
  base_code = NULL,
  data = NULL,
  output = "scripts",
  model = "anthropic/claude-opus-4-5",
  ...
)

prompt_gen_code(
  schema = NULL,
  base_code = NULL,
  data = NULL,
  print = TRUE,
  width = 70
)
```

## Arguments

- x:

  A schema object, multiverse object, or file path to a schema YML.

- base_code:

  Optional. File path to an R script to use as style reference.

- data:

  Optional. Data source specification (file path or "package::dataset").

- output:

  For schemas: file path (ending in .R) or directory. For multiverses:
  must be a directory. Defaults to "scripts".

- model:

  The LLM to use for code generation, as a string in
  \`"provider/model"\` form (e.g. \`"anthropic/claude-opus-4-5"\`,
  \`"openai/gpt-5"\`, \`"google_gemini/gemini-2.5-flash"\`), passed to
  \`ellmer::chat()\`. See \[ellmer::chat()\] for the full list of
  supported providers. Defaults to \`"anthropic/claude-opus-4-5"\`.

- ...:

  Additional arguments passed to methods.

- schema:

  A schema object to include in the prompt.

- print:

  If \`TRUE\`, prints the prompt to console instead of returning it.

- width:

  If \`print = TRUE\`, the width to wrap the printed prompt (default
  70).

## Value

Invisibly returns the path(s) to the generated script(s).

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate from a single schema
schema <- example_schema()
gen_code(schema, output = "analysis.R")

# Generate from a multiverse (use expand_tines first)
schema |>
  expand_tines(alternatives) |>
  gen_code(output = "scripts/")
} # }

# The prompt generation function can be used directly to see the full prompt sent to the LLM
prompt_gen_code(data = "inst/football.csv")
#> You are an expert R programmer. Attached is a text document
#> containing a SCHEMA that defines a data processing pipeline.
#> 
#> A DATA section is provided. This is the entry point for the entire
#> pipeline - start the script by loading this data. Do NOT generate,
#> simulate, or create any dummy or synthetic data under any
#> circumstances. Your task is to write a complete, working R script
#> that implements this pipeline step-by-step. Use modern R practices
#> (like dplyr or base pipe) and ensure variables flow correctly from
#> one step to the next as defined by the inputs and outputs. Output
#> ONLY the complete R script. Do not start with markdown formatting
#> blocks (like ```R) or backticks.
#> 
#> === DATA ===
#> 
#> The data should be imported from the file: `inst/football.csv`. Use
#> `readr::read_csv("inst/football.csv")` (or the appropriate reader) to
#> load it.
```
