# Package index

## Schema

A schema records one analysis as an ordered sequence of decisions.

- [`new_schema()`](schema-constructor.md)
  [`build_schema()`](schema-constructor.md)
  [`add_step()`](schema-constructor.md)
  [`as_schema()`](schema-constructor.md)
  [`as.data.frame(`*`<schema>`*`)`](schema-constructor.md)
  [`print(`*`<schema>`*`)`](schema-constructor.md) : Construct a schema
- [`write_tines()`](read-write.md) [`read_tines()`](read-write.md) :
  Read and write tines schemas and multiverses to YAML files
- [`draft_tines()`](draft_tines.md) : Draft a schema template
- [`extract_schema()`](extract_schema.md)
  [`prompt_extract_schema()`](extract_schema.md) : Extract schema from
  descriptive text
- [`get_step_names()`](get.md) : Functions to access components of a
  tine object

## Mapping a schema to data

Tie each step to the variables it reads and the ones it creates, so the
generated code runs against a real dataset.

- [`gen_io()`](update-io.md) [`update_data()`](update-io.md)
  [`update_io()`](update-io.md) : Data mapping and validation for
  schemas

## Alternatives

Record different ways of carrying out one or more steps of a schema.

- [`alternative()`](alternatives.md) [`node()`](alternatives.md)
  [`new_alternatives()`](alternatives.md) : Construct alternatives
  objects
- [`write_alternatives()`](read-write-alternatives.md)
  [`read_alternatives()`](read-write-alternatives.md) : Read and write
  an alternatives object from/to a YML file
- [`draft_alternatives()`](draft_alternatives.md) : Draft an
  alternatives template
- [`gen_alternatives()`](gen_alternatives.md)
  [`prompt_alternatives()`](gen_alternatives.md) : Generate analytical
  alternatives via LLM

## Multiverse

Expand one analysis into many, or collect several analyses together.

- [`expand_tines()`](expand.md) : Expand a schema with an alternative
  YAML into a multiverse
- [`new_multiverse()`](multiverse-constructor.md)
  [`as_multiverse()`](multiverse-constructor.md) : Construct a
  multiverse

## Generating and validating code

Turn a schema into an R script, then run it and repair what fails.

- [`gen_code()`](gen_code.md) [`prompt_gen_code()`](gen_code.md) :
  Generate R code from a schema or multiverse
- [`validate_script()`](validate_script.md) : Auto-Fix an R Script via
  Iterative LLM Debugging

## Visualising

- [`plot(`*`<schema>`*`)`](print.md)
  [`plot(`*`<multiverse>`*`)`](print.md) [`draw_tines()`](print.md)
  [`inspect_dot()`](print.md) : Visualize and inspect tines objects

## Examples and data

- [`example_schema()`](example_tines.md)
  [`example_multiverse()`](example_tines.md)
  [`example_football()`](example_tines.md)
  [`example_alternatives()`](example_tines.md)
  [`example_football_grp20()`](example_tines.md)
  [`example_football_grp5()`](example_tines.md) : Generate examples
- [`football_grp20`](grp.md) [`football_grp5`](grp.md) : Football red
  cards study methodology text (Group 5 and 20)
