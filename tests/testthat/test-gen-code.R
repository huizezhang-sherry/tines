test_that("prompt_gen_code wording remains stable (snapshot)", {
  expect_snapshot({
    prompt_gen_code(print = FALSE)
  })
  expect_snapshot({
    prompt_gen_code(data = "inst/football.csv", print = FALSE)
  })
  expect_snapshot({
    prompt_gen_code(data = "tines::football", print = FALSE)
  })
  expect_snapshot({
    prompt_gen_code(schema = example_hdi(), print = FALSE)
  })
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
  expect_error(gen_code("no/such/schema.yml", output = tempdir()), "File not found")
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

test_that("gen_code.schema works on an unmapped schema, using its data reference", {
  seen <- NULL
  local_mocked_bindings(gen_code_single = function(...) seen <<- list(...))

  schema <- update_data(example_hdi(), "datasets::mtcars")
  gen_code(schema, output = withr::local_tempdir())
  expect_equal(seen$data, "datasets::mtcars")

  # an explicit `data` overrides the reference
  gen_code(schema, data = "other.csv", output = withr::local_tempdir())
  expect_equal(seen$data, "other.csv")
})

test_that("prompt_gen_code describes a script data source", {
  prompt <- prompt_gen_code(data = "make-data.R", data_object = "df", print = FALSE)
  expect_match(prompt, 'source("make-data.R")', fixed = TRUE)
  expect_match(prompt, "`df`", fixed = TRUE)
})

test_that("prompt_gen_code sends inputs/outputs only when the mapping is complete", {
  incomplete <- suppressMessages(update_io(example_hdi(), "step-scaling", inputs = "a", outputs = "b"))
  expect_no_match(prompt_gen_code(schema = incomplete, print = FALSE), "inputs", fixed = TRUE)
})

test_that("prompt_gen_code asks for the declared names only when mapped", {
  plain <- prompt_gen_code(schema = example_hdi(), print = FALSE)
  expect_no_match(plain, "use exactly those variable names", fixed = TRUE)

  mapped <- add_step(build_schema(), id = "a", inputs = "x", outputs = "y")
  expect_match(prompt_gen_code(schema = mapped, print = FALSE), "use exactly those", fixed = TRUE)
})

test_that("gen_code.multiverse requires a directory for output", {
  mapped_schema <- build_schema() |>
    add_step(id = "step-1", inputs = "x", outputs = "y")
  mv <- as_multiverse(list(branch_a = mapped_schema))

  expect_error(gen_code(mv, output = "pipeline.R"), "must be a directory")
})

test_that("gen_code.multiverse sanitizes branch names into safe filenames", {
  local_mocked_bindings(gen_code_single = function(...) invisible(NULL))

  mapped_schema <- build_schema() |>
    add_step(id = "step-1", inputs = "x", outputs = "y")
  mv <- as_multiverse(list(`branch one!` = mapped_schema, branch_two = mapped_schema))

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
