# Future Extensions

This vignette records design ideas that are **not implemented**. Nothing
here is part of the public API, and none of the code below runs – it
sketches file formats and function signatures under consideration, so
that the reasoning behind them is written down rather than rediscovered
later.

For what the package actually does today, see
[`vignette("schema")`](../articles/schema.md) and
[`vignette("alternatives")`](../articles/alternatives.md).

## Schema composition

### The idea

Analyses share steps. Two drought indices, SPEI and SPI, both begin by
transforming temperature into potential evapotranspiration and by
aggregating a series over a time window. A third index, RDI, reuses one
step from each and adds three of its own. Rather than restating those
shared steps – and regenerating their code, with a fresh chance of
getting it wrong – a schema could **cite** them.

The payoff is not brevity. It is that a cited step can have its
already-written, already-validated implementation lifted verbatim out of
the source analysis’s script, instead of being handed to an LLM to
reimplement. Only the genuinely new steps need generating.

### The problem with the current mechanism

The package has an unexported sketch of this: an internal
`import_step()` tags an imported step with a `source_schema` key, which
an internal `gen_composite_code()` resolves against a `base_scripts`
lookup supplied at code-generation time.

The key is produced by deparsing whatever R expression was passed, so it
is whatever the variable happened to be called:

``` r

# key becomes "spei_template"
import_step(schema, source_schema = spei_template, id = "step-calc-pet")

# key becomes the literal text of the call
import_step(schema, source_schema = read_tines("spei.yml"), id = "step-calc-pet")
```

Written into a file, `source_schema: spei_template` names no file, no
step, and no script. It resolves only if the caller separately passes a
matching `base_scripts = list(spei_template = "spei.R")`, so the
reference is split across three places and joined by an R variable name.
For a reader – the audience the whole package is built for – it is
unfollowable.

### The proposed format

Put a locator in the file, so the schema is self-describing:

``` yaml
meta:
  type: schema
  name: RDI
nodes:
  - id: step-calc-pet
    objective: transform average temperature to obtain PET
    decision: use Thornthwaite equation
    rationale: estimates PET using only mean temperature and latitude
    inputs: [.proxy_tavg]
    outputs: [.proxy_pet]
    source:
      schema: spei.yml          # resolved relative to this file
      step: step-calc-pet       # id in the source; need not match this one
      script: spei.R            # optional: where the implementation lives

  - id: step-calc-ratio
    objective: calculate the ratio of precipitation to PET
    decision: divide precipitation by PET
    rationale: RDI relies on the P/PET ratio rather than the difference
    inputs: [.proxy_prcp, .proxy_pet]
    outputs: [.proxy_ratio]
```

A cited step keeps its own `objective`/`decision`/`rationale` in full,
so the schema still reads as a complete account of the analysis on its
own. The `source` block adds provenance on top, rather than replacing
content with a reference.

What this buys over the current key:

- **It resolves.** `gen_composite_code()` would need no `base_scripts`
  argument; the schema already says where each imported step’s
  implementation lives.
- **A reader can follow it.** `spei.yml#step-calc-pet` is a citation; a
  bare `spei_template` is not.
- **It survives renaming.** The locator is a path and an id, not a
  deparsed variable.
- **Ids may differ.** `step: step-calc-pet` lets the citing schema name
  the step whatever suits it.

Open questions: how paths resolve when the source schema is not
available locally, whether a `source` step should be verified against
the cited schema on read (and whether a mismatch is an error or a
warning), and whether the optional `script` field belongs in the schema
at all or in a separate lockfile-like artifact.

### The alternative worth considering

Composition is exercised by one internal example and no shipped schema
file uses it. If step-level code reuse is not a workflow worth
supporting, the honest move is to delete the path outright rather than
redesign it. This vignette exists partly so that decision can be made
deliberately.

Note that composition is a different axis from the alternatives file,
and neither substitutes for the other:

- an **alternatives file** varies a decision *within* a step, turning
  one analysis into many;
- **composition** reuses a step *from another* analysis, assembling one
  analysis out of parts.
