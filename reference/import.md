# Import a Step from a source schema into the current schema

Import a Step from a source schema into the current schema

Generate edges from a schema based on input/output variable matching

## Usage

``` r
import_step(schema, source_schema, id, source_schema_name = NULL, ...)

generate_edges(schema)
```

## Arguments

- schema:

  A schema object with nodes containing \`inputs\` and \`outputs\`
  list-columns.

- source_schema:

  The schema to import the step from.

- id:

  The id of the step to import.

- source_schema_name:

  Optional. A string to use as the provenance key, matched against
  \`base_scripts\` in \`gen_composite_code()\`. Defaults to the deparsed
  name of \`source_schema\`.

- ...:

  Optional field overrides (e.g. \`inputs = c(".new_var")\`).

## Value

The updated schema with the imported step appended.

The schema with \`edges\` populated.
