test_that("prompt_gen_code wording remains stable (snapshot)", {
  expect_snapshot({prompt_gen_code(print = FALSE)})
  expect_snapshot({prompt_gen_code(data = "inst/football.csv", print = FALSE)})
  expect_snapshot({prompt_gen_code(data = "tines::football", print = FALSE)})
  expect_snapshot({prompt_gen_code(schema = example_schema(), print = FALSE)})
})

test_that("prompt_gen_code includes base_code content when provided", {
  base_code <- withr::local_tempfile(fileext = ".R")
  writeLines(c("library(dplyr)", "df |> filter(x > 0)"), base_code)

  prompt <- prompt_gen_code(base_code = base_code, print = FALSE)

  expect_match(prompt, "BASE R CODE", fixed = TRUE)
  expect_match(prompt, "library(dplyr)", fixed = TRUE)
})

test_that("prompt_gen_code errors when base_code file doesn't exist", {
  expect_error(
    prompt_gen_code(base_code = "no/such/file.R", print = FALSE),
    "Base code file not found"
  )
})

test_that("gen_code.character errors when the file doesn't exist", {
  expect_error(gen_code("no/such/schema.yml"), "File not found")
})

test_that("gen_code.schema resolves the output path correctly", {
  local_mocked_bindings(gen_code_single = function(...) invisible(NULL))

  mapped_schema <- build_schema() |>
    add_step(id = "step-1", inputs = "x", outputs = "y")

  # output given as a directory -> writes pipeline.R inside it
  out_dir <- withr::local_tempdir()
  path <- gen_code(mapped_schema, output = out_dir)
  expect_equal(path, file.path(out_dir, "pipeline.R"))

  # output given as an explicit .R file path
  out_file <- file.path(withr::local_tempdir(), "custom.R")
  path2 <- gen_code(mapped_schema, output = out_file)
  expect_equal(path2, out_file)
  expect_true(dir.exists(dirname(out_file)))
})

test_that("gen_code.schema errors when the schema is unmapped and no data is given", {
  unmapped_schema <- example_football()
  expect_error(
    gen_code(unmapped_schema, output = withr::local_tempdir()),
    "requires inputs/outputs but schema is unmapped"
  )
})

test_that("gen_code.multiverse requires a directory for output", {
  mapped_schema <- build_schema() |>
    add_step(id = "step-1", inputs = "x", outputs = "y")
  mv <- build_multiverse(branch_a = mapped_schema)

  expect_error(gen_code(mv, output = "pipeline.R"), "must be a directory")
})

test_that("gen_code.multiverse sanitizes branch names into safe filenames", {
  local_mocked_bindings(gen_code_single = function(...) invisible(NULL))

  mapped_schema <- build_schema() |>
    add_step(id = "step-1", inputs = "x", outputs = "y")
  mv <- build_multiverse(`branch one!` = mapped_schema, branch_two = mapped_schema)

  out_dir <- withr::local_tempdir()
  paths <- gen_code(mv, output = out_dir)

  expect_equal(basename(paths), c("branch_one.R", "branch_two.R"))
})

test_that("gen_code_single errors without a file_path", {
  mapped_schema <- build_schema() |>
    add_step(id = "step-1", inputs = "x", outputs = "y")

  expect_error(
    gen_code_single(mapped_schema, file_path = NULL),
    "must provide.*file_path"
  )
})
