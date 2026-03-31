# Create templates YAML files

Generates a starter YAML file for a \`schema\` or \`multiverse\` to help
you begin building your garden of forking paths.

## Usage

``` r
draft_tines(
  type = c("schema", "multiverse"),
  file_path = NULL,
  overwrite = FALSE
)

draft_alternatives(x, id, file_path = NULL)
```

## Arguments

- type:

  The type of template to create. Options are "schema" for a new
  analysis schema template, and "multiverse" for a multiverse analysis
  template.

- file_path:

  The file path where the template should be saved. If NULL, the
  template will be saved in the current working directory with a default
  name based on the type.

- overwrite:

  Logical. If TRUE, will overwrite an existing file at the specified
  file_path. Defaults to FALSE.

- x:

  A \`schema\` or \`multiverse\` object. Required for
  \`draft_alternatives()\` to generate a template based on an existing
  step.

- id:

  A character string specifying the \`id\` of the step in the schema

## Examples

``` r
# Create a new schema template
if (FALSE) { # \dontrun{
draft_tines(type = "schema", file_path = "schema_template.yaml")
draft_alternatives(x = my_schema, id = "data-cleaning", file_path = "alternative_template.yaml")
} # }

```
