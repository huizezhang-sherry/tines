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

## Generate analytical alternatives

- [`gen_alternatives()`](gen_alternatives.md)
  [`prompt_alternatives()`](gen_alternatives.md) : Generate analytical
  alternatives via LLM
- [`expand_tines()`](expand.md) : Expand a schema with an alternative
  YAML into a multiverse

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
  [`example_alternatives()`](example_tines.md) : Generate examples
