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

## Value

\`draft_tines()\` and \`draft_alternatives()\` both invisibly return the
path they wrote to; each is called primarily for its side effect of
writing a template YAML file to disk.

## Examples

``` r
# Create a new schema template
schema_path <- withr::local_tempfile(fileext = ".yml")
draft_tines(type = "schema", file_path = schema_path)
#> ✔ Drafted "schema" template at /tmp/RtmpvTS8Ky/file1ad017015b67.yml
#> ℹ Open this file to start defining your steps!

# Draft alternatives from a schema object
my_schema <- example_schema()
draft_alternatives(
  x = my_schema,
  id = "step-scaling",
  file_path = withr::local_tempfile(fileext = ".yml"),
  branch = "multi"
)
#> ✔ Created template at /tmp/RtmpvTS8Ky/file1ad04af73164.yml

# Draft alternatives from a schema file
schema_file <- withr::local_tempfile(fileext = ".yml")
write_tines(my_schema, schema_file)
#> ✔ File saved: /tmp/RtmpvTS8Ky/file1ad0329a1373.yml
draft_alternatives(
  x = schema_file, id = "step-scaling",
  file_path = withr::local_tempfile(fileext = ".yml"), branch = "multi"
)
#> ✔ Created template at /tmp/RtmpvTS8Ky/file1ad03387adf5.yml

# Draft a single-branch template combining two steps together
draft_alternatives(
  x = my_schema,
  id = c("step-scaling", "step-education"),
  file_path = withr::local_tempfile(fileext = ".yml"),
  branch = "single"
)
#> ✔ Created template at /tmp/RtmpvTS8Ky/file1ad02ac7e805.yml
```
