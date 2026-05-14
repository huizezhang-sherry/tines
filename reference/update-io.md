# Data mapping and validation for schemas

These functions manage the relationship between a schema and its
dataset. Here are the four main scenarios they cover:

\* Specify the dataset when creating the schema through
\[build_schema()\] and the inputs/outputs for each step as you add them
with \[add_step()\].

\* Modify the inputs/outputs for a specific step later with
\[update_io()\]. The function will validate the updated mapping against
the attached dataset (if any).

\* Provide a new dataset to an existing schema with \[update_data()\].
The function will validate the entire schema (inputs/outputs) against
the new dataset.

\* Combine the update of data and inputs/outputs in one step with
\[update_io()\] by providing the new dataset using the \`data\`
argument.

## Usage

``` r
gen_io(
  schema,
  data,
  interactive = FALSE,
  model = "gemini-2.5-flash",
  force = FALSE
)

update_data(schema, data)

update_io(schema, id, inputs = NULL, outputs = NULL, data = NULL)
```

## Arguments

- schema:

  A \`schema\` object

- data:

  A data frame or path to a data file. For \`gen_io()\` and
  \`update_data()\`, this is required. For \`update_io()\`, this is
  optional - if provided, validates the updated inputs/outputs against
  this dataset (without attaching it).

- interactive:

  Logical. If TRUE, prompts user for ambiguous mappings

- model:

  Character string specifying which LLM to use

- force:

  Logical. If TRUE, remaps even if already mapped

- id:

  Character string identifying which step to update (for
  \`update_io()\`)

- inputs:

  Character vector of input variable names

- outputs:

  Character vector of output variable names

## Value

A \`schema\` object with updated inputs/outputs and data reference

## Examples

``` r
# Create example datasets
data_2023 <- data.frame(
  age = c(25, 30, 35, NA, 45),
  income = c(50000, 60000, NA, 70000, 80000),
  city = c("NYC", "LA", "Chicago", "NYC", NA)
)

data_2024 <- data.frame(
  age = c(26, 31, 36, 40, 46),
  salary = c(52000, 62000, 68000, 72000, 82000),  # Note: 'salary' not 'income'
  city = c("NYC", "LA", "Chicago", "Boston", "LA")
)

# Scenario 1: 
# specify the dataset when creating the schema through `build_schema()`
schema <- build_schema(data = data_2023) |>
  add_step(
    id = "step-filter", action = "remove missing values", 
    decision = "exclude rows with NA",
    inputs = c("age", "income"), outputs = "df_clean"
  ) |>
  add_step(
    id = "step-transform", action = "log transform income", 
    decision = "use natural log",
    inputs = "df_clean", outputs = "df_transformed"
  )
#> ✔ Data attached: "data_2023"

# Scenario 2: 
# modify the inputs/outputs with `update_io()`
schema_mod <- update_io(schema, "step-filter", inputs = c("age"))

# Scenario 3: 
# provide a new dataset to an existing schema with `update_data()`
# The function will trigger validation and return an error when 
# the mapping is broken (e.g., "income" not found in new dataset)
if (FALSE) { # \dontrun{
schema <- update_data(schema, data_2024)
} # }

# Scenario 4: 
# combine the update of data and inputs/outputs in one step with `update_io()` 
# by providing the new dataset using the `data` argument.
schema_2024 <- update_io(schema, "step-filter",
                    inputs = c("age", "salary", "city"),
                    outputs = "df_clean",
                    data = data_2024)

# LLM approach: auto-infer from dataset (leave untouched)
if (FALSE) { # \dontrun{
schema_llm <- build_schema() |>
  add_step(
    id = "step-filter",
    action = "remove missing values",
    decision = "exclude rows with NA"
  ) |>
  add_step(
    id = "step-transform", 
    action = "log transform income",
    decision = "use natural log"
  ) |>
  gen_io(data = data_2023)
} # }
```
