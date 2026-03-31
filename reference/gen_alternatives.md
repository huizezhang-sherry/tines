# Generate analytical alternatives via LLM

\`gen_alternatives()\` takes an existing \`schema\` or \`multiverse\`
and asks a Large Language Model to suggest methodologically valid,
alternative approaches for a specific step in your analysis pipeline.

\`prompt_alternatives()\` is a helper function that constructs the exact
instruction set sent to the LLM.

## Usage

``` r
gen_alternatives(x, step, n = 3, provider = "gemini", file_path = NULL, ...)

# S3 method for class 'character'
gen_alternatives(x, ...)

# S3 method for class 'schema'
gen_alternatives(x, step, n = 3, provider = "gemini", file_path = NULL, ...)

# S3 method for class 'multiverse'
gen_alternatives(x, step, ...)

prompt_alternatives(schema = NULL, step, n = 3, print = TRUE, width = 70)
```

## Arguments

- x:

  A \`schema\` or \`multiverse\` object, or a character string
  specifying the file path to a valid \`tines\` YAML file.

- step:

  A character string. The exact \`id\` of the step you want the LLM to
  generate alternatives for.

- n:

  An integer. The number of distinct alternatives you want the LLM to
  generate. Defaults to \`3\`.

- provider:

  A character string specifying the LLM provider. Currently defaults to
  \`"gemini"\`. (\`gemini-3-flash-preview\` via \`ellmer\`).

- file_path:

  A character string specifying where to save the generated YAML output.
  If \`NULL\` (the default), \`capture.output()\` will return the result
  as a character vector.

- ...:

  Additional arguments passed to methods or to
  \`ellmer::chat_google_gemini()\`.

- schema:

  A schema object to include in the prompt.

- print:

  If \`TRUE\`, prints the prompt to console instead of returning it.

- width:

  If \`print = TRUE\`, the width to wrap the printed prompt (default
  70).

## Value

\* \`gen_alternatives()\` invisibly returns \`NULL\` and writes the
output to \`file_path\`. \* \`prompt_alternatives()\` returns a
formatted character string containing the LLM prompt.

## Details

\*\*Important:\*\* This function relies on the \`ellmer\` package to
communicate with Google's Gemini API. You must have your API credentials
configured correctly in your R environment (e.g., via the
\`GEMINI_API_KEY\` environment variable) for this to work.

## Examples

``` r
hdi <- example_schema()

if (FALSE) { # \dontrun{
gen_alternatives(hdi, step = "step-combine", n = 1,
                file_path = here::here("inst/hdi-alt.yaml"))
} # }

# The prompt generation function can be used directly to see the full prompt sent to the LLM
prompt_alternatives(schema = hdi, step = "step-combine", print = TRUE)
#> You are an expert Data Analyst and Methodologist. You are reviewing
#> an analysis schema to identify "Forking Paths" -- alternative
#> analytical choices that are equally valid but distinct from the
#> current approach.
#> 
#> === DEFINITIONS ===
#> 
#> The schema provided to you consists of steps with:
#> 
#> - **ACTION**: The goal of the step (What needs to be done).
#> 
#> - **DECISION**: The specific implementation chosen (How it is done).
#> 
#> - **JUSTIFICATION**: The reasoning behind that decision.
#> 
#> - **ID**: The unique identifier for the step (kebab-case).
#> 
#> === TASK ===
#> 
#> Focus specifically on the step tagged: "step-combine". Your goal is
#> to generate 3 distinct, valid alternatives for this step.
#> 
#> For each alternative: 1. **Keep the same ACTION** (the goal remains
#> constant).
#> 
#> 2. **Change the DECISION** to a different but methodologically sound
#> approach.
#> 
#> 3. **Provide a new JUSTIFICATION** explaining why this alternative is
#> valid.
#> 
#> 4. **Create a new ID** that reflects the new decision (must be
#> kebab-case).
#> 
#> === OUTPUT FORMAT ===
#> 
#> Please output the result in **strictly valid YAML format**.
#> 
#> **Crucial Formatting Rules:**
#> 
#> 1. Include a `meta` section at the top with `type: alternative` and
#> the `step`.
#> 
#> 2. Output strictly valid YAML. All text values (decision,
#> justification) must be enclosed in double quotes ("). Do not use
#> block styles (| or >). Do not wrap lines or insert \n characters
#> within the quotes; keep the text as a single continuous string.
#> 
#> 3. Do not include markdown code fences (like ```yaml) or
#> conversational text. Just the raw YAML.
#> 
#> === REQUIRED YAML STRUCTURE EXAMPLE ===
#> 
#> meta: type: tines_alternative step: step-combine alternatives: - id:
#> step-new-method-name action: Repeat the original action decision:
#> "Description of the new decision..."  justification: "This is the
#> reasoning for why this alternative is valid."  - id:
#> step-another-method ...
#> 
#> === CURRENT SCHEMA ===
#> 
#> nodes: id: - step-scaling - step-education - step-combine action: -
#> variables are in different scales - combine the school variables into
#> one dimension - combine the three dimensions into a single index
#> type: - constraint - step - step decision: - apply min-max scaling to
#> each variable - average exp sch and avg sch - use the geometric mean
#> justification: - to put them on the same scale for combination - the
#> most intuitive way - the geometric mean is more appropriate than
#> arithmetic mean inputs: - .na - .na - .na outputs: - .na - .na - .na
#> source_schema: - .na - .na - .na edges: from: - step-scaling -
#> step-combine - step-education to: - step-education - step-scaling -
#> step-combine type: - sequential - motivated - sequential
```
