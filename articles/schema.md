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
- how a schema is mapped to a dataset, and
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
#> ✔ Drafted "schema" template at /tmp/RtmpyA42Q2/file1d0e71a29969.yml
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
#>   id           objective                       decision rationale inputs outputs
#>   <chr>        <chr>                           <chr>    <chr>     <list> <list> 
#> 1 step-scaling variables are in different sca… apply m… to put t… <lgl>  <lgl>  
#> 2 step-combine combine the three dimensions i… use the… the geom… <lgl>  <lgl>
```

[`write_tines()`](../reference/read-write.md) writes it back out as
YAML:

``` r

out_path <- withr::local_tempfile(fileext = ".yml")
write_tines(hdi, out_path)
#> ✔ File saved: /tmp/RtmpyA42Q2/file1d0e926a594.yml
```

``` yaml
meta:
  type: schema
  date: '2026-09-24'
  name: HDI Example
nodes:
- id: step-scaling
  objective: variables are in different scales
  decision: apply min-max scaling to each variable
  rationale: to put them on the same scale for combination
  inputs: []
  outputs: []
- id: step-combine
  objective: combine the three dimensions into a single index
  decision: use the geometric mean
  rationale: the geometric mean penalizes uneven development
  inputs: []
  outputs: []
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
#>   id             objective                     decision rationale inputs outputs
#>   <chr>          <chr>                         <chr>    <chr>     <list> <list> 
#> 1 step-scaling   variables are in different s… apply m… to put t… <chr>  <chr>  
#> 2 step-education combine the school variables… average… the most… <chr>  <chr>  
#> 3 step-combine   combine the three dimensions… use the… the geom… <chr>  <chr>
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
[`update_io()`](../reference/update-io.md). A data frame missing any of
the four required fields is refused, and says which:

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
  text = football_grp20,
  data_dict = c("player", "redCards", "rater1", "rater2"),
  output_file = "draft_schema.yml"
)
```

A schema drafted this way carries extra bookkeeping fields – `status`,
`confidence`, and `clarification_question` – recording how sure the
model was that it read each decision correctly. Any extra field is
preserved as its own column when the file is read, and written back out
unchanged:

``` r

drafted <- example_football_grp20()
colnames(drafted)
#> [1] "id"                     "objective"              "decision"              
#> [4] "rationale"              "status"                 "confidence"            
#> [7] "clarification_question" "inputs"                 "outputs"
```

## Mapping a schema to data

The four core fields describe an analysis, but generating code that runs
against a real dataset also requires knowing which variables each step
consumes and produces. Two optional fields record that:

``` yaml
  - id: step-scaling
    objective: variables are in different scales
    decision: apply min-max scaling to each variable
    rationale: to put them on the same scale for combination
    inputs: [life_exp, exp_sch, avg_sch, gni]
    outputs: [scaled]
```

- **`inputs`** name the variables the step reads.
- **`outputs`** name the variables it creates. An output need not exist
  in the dataset yet – the schema describes the analysis before its code
  exists.

Supply a dataset and `tines` checks the mapping. It walks the steps in
order, starting from the dataset’s own columns, and requires every
step’s `inputs` to be available by that point – either a column of the
original data, or an output created by an earlier step:

``` r

hdi_data <- data.frame(
  life_exp = c(72, 81, 66),
  exp_sch = c(13, 16, 10),
  gni = c(9000, 42000, 3200)
)

mapped <- build_schema(name = "HDI", data = hdi_data) |>
  add_step(
    id = "step-scaling",
    objective = "variables are in different scales",
    decision = "apply min-max scaling to each variable",
    inputs = c("life_exp", "exp_sch", "gni"),
    outputs = "scaled"
  ) |>
  add_step(
    id = "step-combine",
    objective = "combine the dimensions into a single index",
    decision = "use the geometric mean",
    inputs = "scaled",
    outputs = "hdi"
  )
#> ✔ Data attached: "hdi_data"
```

`step-combine` reads `scaled`, which is not a column of `hdi_data` but
is produced by `step-scaling`, so the mapping is valid.

Swapping in a dataset that breaks the mapping is refused outright,
naming the step and the variables it can no longer reach:

``` r

renamed <- data.frame(
  life_exp = c(70, 80, 60),
  exp_sch = c(12, 15, 9),
  income = c(8000, 40000, 3000) # `gni` renamed
)
update_data(mapped, renamed)
#> Error in `update_data()`:
#> ✖ Validation failed - data NOT attached
#>   
#> ℹ Missing variables:
#>   Step 'step-scaling': gni
#>   
#> ℹ Available in new dataset: life_exp, exp_sch, income
#>   
#> ℹ Fix options:
#>   1. Manual fix: update_io(schema, id, inputs = ..., outputs = ..., data = ...)
#>   2. Auto-fix with LLM: gen_io(schema, data, force = TRUE)
```

Three functions maintain the mapping.
[`update_data()`](../reference/update-io.md) attaches a different
dataset and re-validates the whole schema against it, as above.
[`update_io()`](../reference/update-io.md) edits the mapping for a
single step; it warns rather than refuses when a variable is
unreachable, so you can fix several steps in sequence without the
intermediate states blocking you.
[`gen_io()`](../reference/update-io.md) fills in the mapping for every
step at once by asking an LLM to match the steps against the columns of
a dataset.

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
