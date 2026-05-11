test_that("multiplication works", {
  
  # res <- extract_schema_from_text(str_24)

  # res <- extract_schema_from_text(str_20)
  # map_variables(schema_file = here::here("draft_schema.yml"), data = "inst/football.csv")
  # # the inputs/outputs mapping is not desirable at the moment


  # eobj <- read_tines(here::here("draft_schema_mapped.yml"))
  # gen_code(obj, data = "inst/football.csv")
  # validate_script(here::here("scripts/pipeline.R"), data = "inst/football.csv")


  # extract_schema(str_20, data = "inst/football.csv", output_file = here::here("draft_schema_mapped.yml"))

  # obj <- read_tines(here::here("draft_schema_mapped.yml"))
  # gen_code(obj, data = "inst/football.csv")
  # validate_script(here::here("scripts/pipeline.R"), data = "inst/football.csv")
  
})

test_that("extract_schema generates valid YAML schema", {
  
  # vcr::local_cassette("extract_schema", match_requests_on = c("method", "uri", "body_json"))
  
  # text <- "We calculated age by subtracting birth year from 2012. Skin tone was rated on a 1-5 scale."
  # data_dict <- c("birthday", "rater1", "rater2", "age", "skin_tone")

  # output_file <- withr::local_tempfile(fileext = ".yml")  
  
  # result <- extract_schema(text = text, data_dict = data_dict, output_file = output_file)
  
  # expect_snapshot(cat(readLines(output_file), sep = "\n"))
  
  # yaml_parsed <- yaml::read_yaml(output_file)
  # expect_snapshot(yaml_parsed)
})

test_that("prompt_extract_schema formats correctly", {
  data_dict <- c("var1", "var2", "var3")
  text <- "Some methodology text."
  
  result <- prompt_extract_schema(data_dict, text)
  expect_snapshot(cat(result))
})


