# Create templates YAML files

Generates a starter YAML file for a schema to help you begin building
your garden of forking paths. There is no template for a multiverse: a
multiverse is always produced either by combining schema objects with
[`as_multiverse()`](constructor.md), or by expanding a schema with an
alternatives file via [`expand_tines()`](expand.md) – never
hand-authored from a blank template.

## Usage

``` r
draft_tines(file_path = NULL, overwrite = FALSE)

draft_alternatives(x, id, file_path = NULL, branch)
```

## Arguments

- file_path:

  The file path where the template should be saved. If NULL, the
  template will be saved in the current working directory with a default
  name.

- overwrite:

  Logical. If TRUE, will overwrite an existing file at the specified
  file_path. Defaults to FALSE.

- x:

  A `schema` or `multiverse` object, or a character string specifying
  the file path to a valid schema YAML file.

- id:

  A character string specifying the `id` of the step in the schema. For
  `draft_alternatives()`, a vector naming one or more steps – one node
  is drafted per step.

- branch:

  For `draft_alternatives()` only. Required: either `"multi"` (drafts 2
  placeholder alternatives per node) or `"single"` (drafts exactly 1 per
  node). See [`vignette("alternatives")`](../articles/alternatives.md)
  for what the two modes mean when expanded.

## Value

`draft_tines()` and `draft_alternatives()` both invisibly return the
path they wrote to; each is called primarily for its side effect of
writing a template YAML file to disk.

## Examples

``` r
# Create a new schema template
schema_path <- withr::local_tempfile(fileext = ".yml")
draft_tines(file_path = schema_path)
#> ✔ Drafted "schema" template at /tmp/RtmpFB6av5/file1b275e1ac49d.yml
#> ℹ Open this file to start defining your steps!

# Draft alternatives from a schema object
my_schema <- example_schema()
draft_alternatives(
  x = my_schema,
  id = "step-scaling",
  file_path = withr::local_tempfile(fileext = ".yml"),
  branch = "multi"
)
#> ✔ Created template at /tmp/RtmpFB6av5/file1b2739044cc5.yml

# `x` also accepts a path to a schema file -- draft a single-branch
# template combining two steps together
schema_file <- system.file("hdi.yml", package = "tines")
draft_alternatives(
  x = schema_file,
  id = c("step-scaling", "step-education"),
  file_path = withr::local_tempfile(fileext = ".yml"),
  branch = "single"
)
#> ✔ Created template at /tmp/RtmpFB6av5/file1b2741c81503.yml
```
