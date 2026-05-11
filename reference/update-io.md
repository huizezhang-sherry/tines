# Data mapping and validation for schemas

These functions manage the relationship between a schema and its
dataset: - \`gen_io()\`: Uses LLM to automatically infer inputs/outputs
from dataset columns - \`update_io()\`: Manually update inputs/outputs
for a specific step - \`update_data()\`: Switch to a new dataset and
re-validate the schema

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

update_io(schema, step_id, inputs = NULL, outputs = NULL)
```

## Arguments

- schema:

  A \`schema\` object

- data:

  A data frame or path to a data file

- interactive:

  Logical. If TRUE, prompts user for ambiguous mappings

- model:

  Character string specifying which LLM to use

- force:

  Logical. If TRUE, remaps even if already mapped

- step_id:

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

# Build schema with data attached (validates as steps are added)
schema <- build_schema(data = data_2023) |>
  add_step(
    id = "step-filter",
    action = "remove missing values",
    decision = "exclude rows with NA",
    inputs = c("age", "income"),
    outputs = "df_clean"
  ) |>
  add_step(
    id = "step-transform",
    action = "log transform income",
    decision = "use natural log",
    inputs = "df_clean",
    outputs = "df_transformed"
  )
#> ✔ Data attached: "data_2023"

# Switch to new dataset - validation will fail because 'income' doesn't exist
if (FALSE) { # \dontrun{
schema <- update_data(schema, data_2024)
# Error: Validation failed - data NOT attached
# Missing variables:
#   Step 'step-filter': income
# Available in new dataset: age, salary, city
} # }

# Fix the inputs to use 'salary' instead of 'income'
schema2 <- update_io(schema, "step-filter",
                    inputs = c("age", "salary", "city"),
                    outputs = "df_clean")

# Now update_data() will succeed
schema_2024 <- update_data(schema2, data_2024)
#> ✔ Validation passed
#> ✔ Data attached: "data_2024"

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
