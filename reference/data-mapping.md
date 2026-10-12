# Map a schema to data

A schema's four core fields describe an analysis without reference to
any dataset. It can also carry a reference to the data it runs on, and
be *mapped*: every step given the variables it reads (`inputs`) and
creates (`outputs`). Mapping is optional – [`gen_code()`](gen_code.md)
works on a schema without it. A mapped schema can be checked against its
data before any code is generated, constrains the variable names the
generated code uses, and lets [`draw_tines()`](print.md) draw data-flow
edges.

A schema is in one of three states, and the state belongs to the whole
schema, never to one step:

- **plain** – no step has inputs/outputs;

- **incomplete** – some steps do. What has been written is kept (and
  written to file), but nothing relies on it: it is not checked, not
  drawn and not given to [`gen_code()`](gen_code.md). A message names
  the steps still missing;

- **mapped** – every step has both.

The functions:

- `update_data()` sets the data reference: a data file, a
  `"package::dataset"` string, an R script that builds the data, or a
  data frame.

- `gen_io()` drafts the inputs/outputs of every step with an LLM, for
  you to review. It is never called implicitly. This is the recommended
  way to map a schema: inputs and outputs written by hand are easy to
  get wrong, so a hand-written schema is best left unmapped.

- `update_io()` sets the inputs/outputs of one step, to correct a
  drafted mapping. [`add_step()`](schema-constructor.md) takes the same
  `inputs`/`outputs` arguments, and they can be written in the YAML
  file.

Every one of these re-checks the schema with
[`validate_schema()`](validate_schema.md) and warns about any problem
the change introduced, so a broken mapping is caught when it is made.
See the "Mapping a schema to data" section of
[`vignette("schema")`](../articles/schema.md) for an overview.

## Usage

``` r
update_data(schema, data, object = NULL)

update_io(schema, id, inputs = NULL, outputs = NULL)

gen_io(schema, data = NULL, object = NULL, model = "anthropic/claude-opus-4-5")
```

## Arguments

- schema:

  A `schema` object.

- data:

  The data the schema runs on: a path to a data file (`.csv`, `.rds`,
  `.rda`), a `"package::dataset"` string, a path to an R script that
  creates the data, or a data frame. Only the column names and types are
  kept; the data itself is never stored on the schema. A data frame
  gives no reference that can be written to a file, so it is used for
  checking only.

- object:

  For an R script, the name of the object the script creates that holds
  the data. If `NULL`, the script must create exactly one data frame.

- id:

  The id of the step to update.

- inputs, outputs:

  Character vectors of variable names; `character(0)` records that the
  step has none. `NULL` leaves the field unchanged, and `NA` clears it.

- model:

  The LLM to use for `gen_io()`, as a string in `"provider/model"` form
  (e.g. `"anthropic/claude-opus-4-5"`, `"openai/gpt-5"`,
  `"google_gemini/gemini-2.5-flash"`), passed to
  [`ellmer::chat()`](https://ellmer.tidyverse.org/reference/chat-any.html).
  Defaults to `"anthropic/claude-opus-4-5"`.

## Value

A `schema` object.

## See also

[`validate_schema()`](validate_schema.md) for what the checks cover.

## Examples

``` r
hdi_data <- data.frame(
  life_exp = c(72, 81, 66),
  exp_sch = c(13, 16, 10),
  gni = c(9000, 42000, 3200)
)

# map each step by hand as you add it
schema <- build_schema("HDI", data = hdi_data) |>
  add_step(
    id = "step-scaling", decision = "apply min-max scaling",
    inputs = c("life_exp", "exp_sch", "gni"), outputs = "scaled"
  ) |>
  add_step(
    id = "step-combine", decision = "use the geometric mean",
    inputs = "scaled", outputs = "hdi"
  )

# map a plain schema by hand, one step at a time
plain <- example_hdi() |>
  update_io("step-scaling", inputs = c("life_exp", "exp_sch"), outputs = "scaled")
#> ℹ The mapping is incomplete: steps `step-education`, `step-combine` have no
#>   inputs/outputs yet (1 of 3 steps mapped). Until every step has them, they are
#>   kept but not checked or used.

# edit one step: renaming an output flags the step that still reads it
schema <- update_io(schema, "step-scaling", outputs = "df_scaled")
#> Warning: The schema's inputs/outputs have 1 problem:
#> ! Step `step-combine` reads `scaled`, which is neither a data column nor
#>   created by an earlier step.

# ...and fixed
schema <- update_io(schema, "step-combine", inputs = "df_scaled")

# point the schema at a dataset whose columns no longer match
renamed <- data.frame(life_exp = 70, exp_sch = 12, income = 8000)
schema <- update_data(schema, renamed)
#> Warning: The schema's inputs/outputs have 1 problem:
#> ! Step `step-scaling` reads `gni`, which is neither a data column nor created
#>   by an earlier step.

if (FALSE) { # \dontrun{
# Requires an LLM API key (e.g. ANTHROPIC_API_KEY); not run automatically.
example_hdi() |>
  gen_io(data = hdi_data)
} # }
```
