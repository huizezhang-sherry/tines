# Package index

## Class constructor

- [`new_schema()`](constructor.md) [`build_schema()`](constructor.md)
  [`new_multiverse()`](constructor.md)
  [`build_multiverse()`](constructor.md) [`add_block()`](constructor.md)
  [`add_dependency()`](constructor.md) [`as_schema()`](constructor.md)
  [`as_multiverse()`](constructor.md)
  [`c(`*`<schema>`*`)`](constructor.md)
  [`c(`*`<multiverse>`*`)`](constructor.md) : Construct \`schema\` and
  \`multiverse\` objects
- [`plot(`*`<schema>`*`)`](print.md)
  [`plot(`*`<multiverse>`*`)`](print.md) [`draw_tines()`](print.md)
  [`inspect_dot()`](print.md) : Visualize and inspect \`tines\` objects
- [`alternative()`](alternatives.md)
  [`new_alternatives()`](alternatives.md) : Construct \`alternatives\`
  objects
- [`import_block()`](import.md) [`generate_edges()`](import.md) : Import
  a block from a source schema into the current schema

## Generate analytical alternatives and corresponding code

- [`gen_alternatives()`](gen_alternatives.md)
  [`prompt_alternatives()`](gen_alternatives.md) : Generate analytical
  alternatives via LLM
- [`expand_tines()`](expand.md) : Expand a schema with an alternative
  YAML into a multiverse
- [`extract_and_map_schema()`](extract_and_map_schema.md) : Extract
  Pipeline Schema from Text
- [`gen_code()`](gen_code.md) [`prompt_code()`](gen_code.md) : Generate
  R code for a specific alternative branch
- [`validate_script()`](validate_script.md) : Auto-Fix an R Script via
  Iterative LLM Debugging

## Create new tines from existing tines

- [`gen_composite_code()`](gen_composite_code.md) : Generate R code from
  a composite schema assembled from multiple source schemas

## Interface with YAML files

- [`draft_tines()`](template.md) [`draft_alternatives()`](template.md) :
  Create templates YAML files
- [`write_tines()`](read-write.md) [`read_tines()`](read-write.md) :
  Read and write tines schemas and multiverses to YAML files
- [`write_alternatives()`](read-write-alternatives.md)
  [`read_alternatives()`](read-write-alternatives.md) : Read and write
  an alternatives object from/to a YAML file

## Utility

- [`get_block_names()`](get.md) : Functions to access components of a
  tine object
- [`example_schema()`](example_tines.md)
  [`example_multiverse()`](example_tines.md)
  [`example_football()`](example_tines.md)
  [`example_alternatives()`](example_tines.md)
  [`example_spei()`](example_tines.md)
  [`example_spi()`](example_tines.md)
  [`example_rdi()`](example_tines.md) : Generate examples
- [`football_grp20`](football_grp20.md) : Football red cards study
  methodology text (Group 20)
