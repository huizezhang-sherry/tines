test_that("read and write", {
  # Helper function to scrub dynamic dates from files before snapshotting
  scrub_date_for_snapshot <- function(file_path) {
    lines <- readLines(file_path)
    # Look for the date string and replace it with a static placeholder
    lines <- sub("date:.*[0-9]{4}-[0-9]{2}-[0-9]{2}.*", "date: YYYY-MM-DD", lines)
    writeLines(lines, file_path)
    return(file_path)
  }

  # work for singles
  schema <- example_hdi()
  temp_path <- withr::local_tempfile(fileext = ".yaml")
  write_tines(schema, temp_path)
  scrub_date_for_snapshot(temp_path)
  schema_read <- read_tines(temp_path)
  expect_snapshot_file(temp_path, name = "schema.yaml")
  expect_snapshot(schema_read)

  # additional arguments are passed to yaml::write_yaml
  write_tines(schema, temp_path, indent = 4)
  temp_path <- scrub_date_for_snapshot(temp_path)
  expect_snapshot_file(temp_path, name = "schema-indented.yaml")

  # work for multiverse
  my_multiverse <- example_hdi_multiverse()
  temp_path <- withr::local_tempfile(fileext = ".yaml")
  write_tines(my_multiverse, temp_path)
  temp_path <- scrub_date_for_snapshot(temp_path)
  multiverse_read <- read_tines(temp_path)

  expect_snapshot_file(temp_path, name = "multiverse.yaml")
  expect_snapshot(multiverse_read)
})

test_that("a plain schema is written without inputs/outputs and read back plain", {
  path <- withr::local_tempfile(fileext = ".yml")
  write_tines(example_hdi(), path)
  expect_false(any(grepl("inputs|outputs", readLines(path))))
  expect_false(tines:::is_mapped(read_tines(path)))
})

test_that("`[]` and an incomplete mapping both survive a file", {
  schema <- build_schema() |>
    add_step(id = "a", inputs = character(0), outputs = "x") |>
    add_step(id = "b", inputs = "x", outputs = character(0))
  path <- withr::local_tempfile(fileext = ".yml")
  write_tines(schema, path)
  back <- read_tines(path)
  expect_equal(back$inputs[[1]], character(0))
  expect_equal(back$outputs[[2]], character(0))

  writeLines(c(
    "meta:", "  type: schema",
    "nodes:",
    "- id: a", "  objective: o", "  decision: d", "  rationale: r",
    "  inputs: [x]", "  outputs: [y]",
    "- id: b", "  objective: o", "  decision: d", "  rationale: r"
  ), path)
  expect_message(back <- read_tines(path), "incomplete")
  expect_equal(tines:::unmapped_steps(back), "b")

  # written back as it stands, so it can be finished later
  write_tines(back, path)
  expect_equal(tines:::unmapped_steps(suppressMessages(read_tines(path))), "b")
})

test_that("a data file path is stored relative to the YAML file", {
  dir <- withr::local_tempdir()
  withr::local_dir(dir)
  dir.create("data")
  dir.create("schemas")
  utils::write.csv(data.frame(x = 1), "data/d.csv", row.names = FALSE)

  schema <- build_schema(data = "data/d.csv") |>
    add_step(id = "a", inputs = "x", outputs = "y")
  write_tines(schema, "schemas/s.yml")
  expect_true(any(grepl("source: ../data/d.csv", readLines("schemas/s.yml"), fixed = TRUE)))

  back <- read_tines("schemas/s.yml")
  expect_equal(attr(back, "data")$source, "data/d.csv")
  expect_equal(attr(back, "data")$columns$name, "x")
})

test_that("reading checks a mapped schema against its data", {
  dir <- withr::local_tempdir()
  utils::write.csv(data.frame(x = 1), file.path(dir, "d.csv"), row.names = FALSE)
  schema <- build_schema(data = file.path(dir, "d.csv")) |>
    add_step(id = "a", inputs = "x", outputs = "y")
  path <- file.path(dir, "s.yml")
  write_tines(schema, path)

  # the data changed since the schema was written
  utils::write.csv(data.frame(renamed = 1), file.path(dir, "d.csv"), row.names = FALSE)
  expect_warning(read_tines(path), "`x`")

  # `data` checks against something else instead
  expect_no_warning(read_tines(path, data = data.frame(x = 2)))

  # a missing data file is a warning, not an error
  unlink(file.path(dir, "d.csv"))
  expect_warning(read_tines(path), "not found")
})

test_that("a script source runs only with permission", {
  dir <- withr::local_tempdir()
  writeLines("df <- data.frame(x = 1)", file.path(dir, "make.R"))
  schema <- build_schema(data = file.path(dir, "make.R")) |>
    add_step(id = "a", inputs = "x", outputs = "y")
  path <- file.path(dir, "s.yml")
  write_tines(schema, path)

  # not interactive: skipped, with a note on how to run it
  local_mocked_bindings(is_interactive = function() FALSE)
  expect_message(back <- read_tines(path), "was not run")
  expect_null(attr(back, "data")$columns)

  expect_equal(attr(read_tines(path, validate = "always"), "data")$columns$name, "x")
  expect_null(attr(read_tines(path, validate = "never"), "data")$columns)

  # interactive: the answer decides
  local_mocked_bindings(is_interactive = function() TRUE, ask_run_script = function(...) FALSE)
  expect_null(attr(suppressMessages(read_tines(path)), "data")$columns)
  local_mocked_bindings(ask_run_script = function(...) TRUE)
  expect_equal(attr(read_tines(path), "data")$columns$name, "x")
})

test_that("a plain schema's data is not looked up on read", {
  path <- withr::local_tempfile(fileext = ".yml")
  writeLines(c(
    "meta:", "  type: schema", "  data:", "    source: no/such/file.csv",
    "nodes:", "- id: a", "  objective: o", "  decision: d", "  rationale: r"
  ), path)
  expect_no_warning(back <- read_tines(path))
  expect_null(attr(back, "data")$columns)
})

test_that("a data frame is noted, not written, as the data reference", {
  schema <- build_schema(data = data.frame(x = 1)) |>
    add_step(id = "a", inputs = "x", outputs = "y")
  path <- withr::local_tempfile(fileext = ".yml")
  expect_message(write_tines(schema, path), "no data reference was written")
  expect_false(any(grepl("data:", readLines(path))))
})

test_that("no function writes to a default location", {
  # CRAN policy: a path is always given explicitly, never defaulted into the
  # working directory
  schema <- example_hdi()
  expect_error(write_tines(schema), "`path` is required")
  expect_error(draft_tines(), "`file_path` is required")
  expect_error(
    draft_alternatives(schema, id = "step-scaling", branch = "multi"),
    "`file_path` is required"
  )
  expect_error(gen_code(schema), "`output` is required")
  expect_error(gen_alternatives(schema, step = "step-combine"), "`file_path` is required")
  expect_error(extract_schema("text", "x"), "`output_file` is required")
})
