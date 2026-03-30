# Extract schema from descriptive text

Takes a plain English description of a methodology and uses an LLM
(Large Language Model) to translate it into a structured YAML schema
suitable for multiverse analysis. The function automatically maps
variables from the provided data dictionary to the extracted
methodological steps, identifying inputs and outputs for each node in
the analysis pipeline.

## Usage

``` r
extract_schema(
  text,
  data_dict,
  output_file = "draft_schema.yml",
  model = "gemini-2.5-pro"
)

prompt_extract_schema(data_dict, text)
```

## Arguments

- text:

  A character string containing the methodology description.

- data_dict:

  Either a character vector of column names, or a data frame with at
  least a \`name\` column and an optional \`description\` column.

- output_file:

  The file path where the YAML should be saved.

- model:

  The LLM to use (defaults to Gemini 2.5 Pro).

## Value

The file path to the generated YAML file (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage:
text <- football_grp20
data_dict <- c("playerShort", "player", "club", "leagueCountry", "birthday", "height",
               "weight", "position", "games", "victories", "ties", "defeats",
               "goals", "yellowCards", "yellowReds", "redCards", "photoID", "rater1",
               "rater2", "refNum", "refCountry", "Alpha_3", "meanIAT", "nIAT",
               "seIAT", "meanExp", "nExp", "seExp")
extract_schema(text, data_dict, output_file = "draft_schema.yml")
} # }
```
