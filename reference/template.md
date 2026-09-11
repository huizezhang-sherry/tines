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

draft_alternatives(x, id, file_path = NULL, branch)
```

## Arguments

- type:

  For \`draft_tines()\` only: the type of template to create. Options
  are "schema" for a new analysis schema template, and "multiverse" for
  a multiverse analysis template.

- file_path:

  The file path where the template should be saved. If NULL, the
  template will be saved in the current working directory with a default
  name based on the type.

- overwrite:

  Logical. If TRUE, will overwrite an existing file at the specified
  file_path. Defaults to FALSE.

- x:

  A \`schema\` or \`multiverse\` object, or a character string
  specifying the file path to a valid schema YAML file.

- id:

  A character string specifying the \`id\` of the step in the schema.
  For \`draft_alternatives()\`, a vector naming one or more steps – one
  node is drafted per step.

- branch:

  For \`draft_alternatives()\` only. Required: either \`"multi"\`
  (drafts 2 placeholder alternatives per node) or \`"single"\` (drafts
  exactly 1 per node, for a template meant to combine into one
  coordinated branch). There is no default – see \[alternative()\] for
  what the two modes mean when expanded.

## Examples

``` r
# Create a new schema template
if (FALSE) { # \dontrun{
draft_tines(type = "schema", file_path = "schema_template.yml")

# Draft alternatives from a schema object
draft_alternatives(
  x = my_schema,
  id = "data-cleaning",
  file_path = "alternative_template.yml",
  branch = "multi"
)

# Draft alternatives from a schema file
draft_alternatives(x = "path/to/schema.yml", id = "data-cleaning", branch = "multi")

# Draft a single-branch template combining two steps together
draft_alternatives(
  x = my_schema,
  id = c("data-cleaning", "modeling"),
  branch = "single"
)
} # }
```
