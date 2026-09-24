# Draft an alternatives template

Writes a starter alternatives YAML file, with one node per step named in
`id` and placeholder alternatives inside each, ready to fill in by hand.

## Usage

``` r
draft_alternatives(x, id, file_path = NULL, branch)
```

## Arguments

- x:

  A `schema` object, or the path to a schema YAML file.

- id:

  The `id` of the step to draft alternatives for; a vector names
  several, and one node is drafted per step.

- file_path:

  Where to save the template. If `NULL`, it is written to the working
  directory, named after the steps it covers.

- branch:

  Required: either `"multi"` (drafts 2 placeholder alternatives per
  node) or `"single"` (drafts exactly 1 per node). See
  [`vignette("alternatives")`](../articles/alternatives.md) for what the
  two modes mean when expanded.

## Value

Invisibly, the path written to; called for its side effect of writing
the file.

## See also

[`gen_alternatives()`](gen_alternatives.md) to have an LLM propose them
instead, and [`read_alternatives()`](read-write-alternatives.md) to read
the filled-in file back.

## Examples

``` r
my_schema <- example_schema()

draft_alternatives(
  x = my_schema,
  id = "step-scaling",
  file_path = withr::local_tempfile(fileext = ".yml"),
  branch = "multi"
)
#> ✔ Created template at /tmp/RtmpwUOPUJ/file1a5141d037f0.yml

# `x` also accepts a path to a schema file -- draft a single-branch
# template combining two steps together
draft_alternatives(
  x = system.file("hdi.yml", package = "tines"),
  id = c("step-scaling", "step-education"),
  file_path = withr::local_tempfile(fileext = ".yml"),
  branch = "single"
)
#> ✔ Created template at /tmp/RtmpwUOPUJ/file1a517cf2b428.yml
```
