# Check a schema

Checks a schema's structure and, if it is mapped, its inputs and
outputs. Every function that builds or changes a schema –
[`build_schema()`](schema-constructor.md),
[`add_step()`](schema-constructor.md), [`update_io()`](data-mapping.md),
[`update_data()`](data-mapping.md), [`read_tines()`](read-write.md),
[`as_schema()`](schema-constructor.md), [`expand_tines()`](expand.md) –
runs these checks and reports the problems its change introduced;
[`gen_code()`](gen_code.md) and [`draw_tines()`](print.md) run them
before using a schema. Call `validate_schema()` yourself after editing a
schema directly, e.g. with `schema$inputs[[2]] <- ...`.

**Structure** (an error): the `id`, `objective`, `decision` and
`rationale` fields exist, and ids are present and unique.

**Completeness** (a message): if some steps have inputs/outputs but not
all, the mapping is incomplete. It is kept, but the checks below wait
until every step has both.

**Inputs and outputs** (a warning), for a mapped schema, walking the
steps in order:

- no two steps create the same output;

- no step reads a variable that only a later step creates;

- if the data's columns are known, every input is either a column or the
  output of an earlier step.

## Usage

``` r
validate_schema(x)
```

## Arguments

- x:

  A `schema` object.

## Value

`x`, invisibly.

## See also

[`update_io()`](data-mapping.md) and [`update_data()`](data-mapping.md)
to fix what it reports, and [`validate_script()`](validate_script.md) to
check the generated code by running it.

## Examples

``` r
schema <- build_schema(data = data.frame(x = 1:3)) |>
  add_step(id = "a", decision = "d", inputs = "x", outputs = "y") |>
  add_step(id = "b", decision = "d", inputs = "y", outputs = "z")

# an edit made directly on the tibble skips the checks...
schema$inputs[[2]] <- "w"

# ...so run them yourself
validate_schema(schema)
#> Warning: The schema's inputs/outputs have 1 problem:
#> ! Step `b` reads `w`, which is neither a data column nor created by an earlier
#>   step.
```
