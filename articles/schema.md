# Structuring Schema Files

``` r

library(tines)
```

A **schema** records a data analysis as an ordered sequence of
decisions, each written in natural language. It is the central object in
`tines`: code is generated from it, and it is what an alternatives file
modifies to produce a multiverse. This vignette covers

- the anatomy of a schema YAML file,
- the five ways to create one – from a template, in R, from a file, from
  a data frame, or from prose with an LLM,
- how a schema can optionally be mapped to a dataset, and
- how pairing one with an alternatives file turns it into a multiverse.

## The big picture

A schema file has two parts: a `meta` block marking the document as a
schema, and a `nodes` list holding the steps of the analysis. The
skeleton always looks like this:

``` yaml
meta:
  type: schema
  name: <optional label for the analysis>
nodes:
  - id: <step id>
    objective: <the problem this step solves>
    decision: <what was done>
    rationale: <why it was done that way>
  - id: <step id>
    ...
```

Each step carries four fields:

- **`id`** names the step. Ids must be unique within a schema, and they
  are how an alternatives file points at the step it overrides.
- **`objective`** states the problem the step addresses – the question,
  not the answer.
- **`decision`** records what was actually done.
- **`rationale`** records why it was done that way. This is the field
  that lets a reader agree or disagree with a choice, rather than only
  observe it.

You can initialize the template above via
[`draft_tines()`](../reference/draft_tines.md), and fill in the steps by
hand. Apart from that, there are four ways to create a schema:

| If you are starting from | Use |
|----|----|
| nothing, and you would rather write YAML | [`draft_tines()`](../reference/draft_tines.md), fill in the template, then [`read_tines()`](../reference/read-write.md) |
| nothing, and you would rather work in R | [`build_schema()`](../reference/schema-constructor.md), then one [`add_step()`](../reference/schema-constructor.md) per decision |
| a schema file written earlier | `read_tines(path)` |
| a table of decisions, say from a spreadsheet | `as_schema(df)` |
| prose, such as a manuscript’s methods section | `extract_schema(text, data_dict)` |

All five converge on the same thing: a `schema` object, which is a
tibble of steps. The YAML file is the format you store and share; the
object is what you work with in R. Most functions that consume a schema
([`expand_tines()`](../reference/expand.md),
[`gen_code()`](../reference/gen_code.md),
[`draw_tines()`](../reference/print.md)) take either. Below we show
examples of creating a schema in each of the five ways.

## Creating a schema

### From a template

[`draft_tines()`](../reference/draft_tines.md) writes a skeleton with
two placeholder steps, ready to fill in by hand:

``` r

draft_path <- withr::local_tempfile(fileext = ".yml")
draft_tines(file_path = draft_path)
#> ✔ Drafted "schema" template at /tmp/RtmpNtaaLO/file1cd92adfd8cc.yml
#> ℹ Open this file to start defining your steps!
```

``` yaml
meta:
  type: schema
nodes:
- id: step1
  objective: describe your first step here
  decision: describe your decision here
  rationale: explain your reasoning here
- id: step2
  objective: describe your next step here
  decision: describe your decision here
  rationale: explain your reasoning here
```

### In R

[`build_schema()`](../reference/schema-constructor.md) starts an empty
schema and [`add_step()`](../reference/schema-constructor.md) appends to
it, one step per decision:

``` r

hdi <- build_schema(name = "HDI Example") |>
  add_step(
    id = "step-scaling",
    objective = "variables are in different scales",
    decision = "apply min-max scaling to each variable",
    rationale = "to put them on the same scale for combination"
  ) |>
  add_step(
    id = "step-combine",
    objective = "combine the three dimensions into a single index",
    decision = "use the geometric mean",
    rationale = "the geometric mean penalizes uneven development"
  )
hdi
#> # A schema: HDI Example
#>   id           objective                                      decision rationale
#>   <chr>        <chr>                                          <chr>    <chr>    
#> 1 step-scaling variables are in different scales              apply m… to put t…
#> 2 step-combine combine the three dimensions into a single in… use the… the geom…
```

[`write_tines()`](../reference/read-write.md) writes it back out as
YAML:

``` r

out_path <- withr::local_tempfile(fileext = ".yml")
write_tines(hdi, out_path)
#> ✔ File saved: /tmp/RtmpNtaaLO/file1cd959243ad9.yml
```

``` yaml
meta:
  type: schema
  date: '2026-11-17'
  name: HDI Example
nodes:
- id: step-scaling
  objective: variables are in different scales
  decision: apply min-max scaling to each variable
  rationale: to put them on the same scale for combination
- id: step-combine
  objective: combine the three dimensions into a single index
  decision: use the geometric mean
  rationale: the geometric mean penalizes uneven development
```

### From a file

Most often the schema already exists.
[`read_tines()`](../reference/read-write.md) reads one in – here the
Human Development Index example shipped with the package, which combines
health, education, and standard of living into a single index:

``` yaml
meta:
  type: schema
  date: '2026-09-10'
  name: HDI Example
nodes:
- id: step-scaling
  objective: variables are in different scales
  decision: apply min-max scaling to each variable
  rationale: to put them on the same scale for combination
- id: step-education
  objective: combine the school variables into one dimension
  decision: average exp sch and avg sch
  rationale: the most intuitive way
- id: step-combine
  objective: combine the three dimensions into a single index
  decision: use the geometric mean
  rationale: the geometric mean is more appropriate than arithmetic mean
```

``` r

schema <- read_tines(schema_path)
schema
#> # A schema: HDI Example
#>   id             objective                                    decision rationale
#>   <chr>          <chr>                                        <chr>    <chr>    
#> 1 step-scaling   variables are in different scales            apply m… to put t…
#> 2 step-education combine the school variables into one dimen… average… the most…
#> 3 step-combine   combine the three dimensions into a single … use the… the geom…
```

Because the result is a tibble, the decisions of an analysis can be
inspected with the tools you already use for data frames:

``` r

schema$id
#> [1] "step-scaling"   "step-education" "step-combine"
schema$rationale[schema$id == "step-combine"]
#> [1] "the geometric mean is more appropriate than arithmetic mean"
```

### From a data frame

Decisions are often catalogued somewhere else first – a spreadsheet, or
a table in a lab notebook. Any data frame carrying the four step fields
coerces directly:

``` r

steps <- data.frame(
  id = c("step-clean", "step-model"),
  objective = c("handle missing values", "estimate the effect"),
  decision = c("drop incomplete cases", "fit a linear model"),
  rationale = c("listwise deletion keeps the sample interpretable",
                "the relationship is assumed linear")
)

as_schema(steps, name = "From a spreadsheet")
#> # A schema: From a spreadsheet
#>   id         objective             decision              rationale              
#>   <chr>      <chr>                 <chr>                 <chr>                  
#> 1 step-clean handle missing values drop incomplete cases listwise deletion keep…
#> 2 step-model estimate the effect   fit a linear model    the relationship is as…
```

`inputs` and `outputs` may be supplied as list-columns if you have them;
otherwise add them later with
[`update_io()`](../reference/data-mapping.md). A data frame missing any
of the four required fields is refused, and says which:

``` r

as_schema(steps[, c("id", "decision")])
#> Error in `as_schema()`:
#> ! Cannot coerce to a <schema>: columns objective and rationale are
#>   missing.
#> ℹ A schema needs one row per step, with columns id, objective, decision, and
#>   rationale.
```

### From a manuscript, with an LLM

[`extract_schema()`](../reference/extract_schema.md) drafts a schema
from a prose description of the methodology, such as the methods section
of a paper:

``` r

# Requires an LLM API key (e.g. ANTHROPIC_API_KEY); not run automatically.
extract_schema(
  text = football_grp5,
  data_dict = c("player", "redCards", "rater1", "rater2"),
  output_file = tempfile(fileext = ".yml")
)
```

A schema drafted this way carries extra bookkeeping fields –
`confidence` and `clarification_question` – recording how sure the model
was that it read each decision correctly. Any extra field is preserved
as its own column when the file is read, and written back out unchanged:

``` r

drafted <- example_football_grp5()
colnames(drafted)
#> [1] "id"                     "objective"              "decision"              
#> [4] "rationale"              "confidence"             "clarification_question"
#> [7] "inputs"                 "outputs"
```

## Mapping a schema to data

A schema’s four core fields describe an analysis without reference to
any dataset, and that is enough to generate code:
[`gen_code()`](../reference/gen_code.md) leaves the LLM to work out
which variables each step uses, and
[`validate_script()`](../reference/validate_script.md) then runs the
script on the real data. Optionally, a schema can also record the data
it runs on and be *mapped*, giving every step the variables it reads
(`inputs`) and creates (`outputs`):

``` yaml
meta:
  type: schema
  name: HDI
  data:
    source: data/hdi.csv
nodes:
- id: step-scaling
  objective: variables are in different scales
  decision: apply min-max scaling to each variable
  rationale: to put them on the same scale for combination
  inputs: [life_exp, exp_sch, gni]
  outputs: [scaled]
```

A mapped schema can be checked against its data before any code is
generated, and [`draw_tines()`](../reference/print.md) draws it by data
flow rather than by step order. Most schemas are never mapped. If you
write a schema by hand, we recommend leaving inputs and outputs out,
since they are easy to get wrong. If an LLM drafts it and is given the
data, it maps the variables as well. Either way, you can review the
inputs and outputs and modify them.

The data a schema runs on is a data file (`.csv`, `.rds`, `.rda`), a
package dataset (`"VGAMdata::smqP"`), an R script that creates the data,
or a data frame. The schema keeps only this reference and the data’s
column names, never the data itself. A file path is written relative to
the YAML file, so the two can be moved together; a data frame has no
reference that can be written down.
[`gen_code()`](../reference/gen_code.md) uses the reference to load the
data, so it is worth setting even on a schema that is not mapped.

## From one schema to many

A schema describes one analysis. Pairing it with an **alternatives
file** – which records different ways of carrying out one or more of its
steps – and passing both to [`expand_tines()`](../reference/expand.md)
produces a `multiverse`, one schema per branch the alternatives file
describes, alongside the original:

``` r

alts <- read_alternatives(system.file("hdi-alt-single.yml", package = "tines"))
expand_tines(schema, alts)
#> A multiverse with 2 schemas:
#>   original: "HDI Example" (3 steps)
#>   step-scaling-zscore+step-education-max: "HDI Example" (3 steps)
```

See [`vignette("alternatives")`](../articles/alternatives.md) for the
anatomy of an alternatives file and the two ways it can be expanded.
