# tests/testthat/test-drafts.R

# Helper function to scrub dynamic dates from files before snapshotting
scrub_date_for_snapshot <- function(file_path) {
  lines <- readLines(file_path)
  # Look for the date string and replace it with a static placeholder
  lines <- sub("date:.*[0-9]{4}-[0-9]{2}-[0-9]{2}.*", "date: YYYY-MM-DD", lines)
  writeLines(lines, file_path)
  return(file_path)
}

test_that("draft_tines generates correct schema YAML", {
  # schema
  tmp <- withr::local_tempfile(fileext = ".yaml")
  draft_tines(type = "schema", file_path = tmp)
  tmp <- scrub_date_for_snapshot(tmp)
  expect_snapshot_file(tmp, "schema_template.yaml")

  # multiverse
  tmp <- withr::local_tempfile(fileext = ".yaml")
  draft_tines(type = "multiverse", file_path = tmp)
  tmp <- scrub_date_for_snapshot(tmp)
  expect_snapshot_file(tmp, "multiverse_template.yaml")
})

test_that("draft_alternatives generates correct multi-branch alternatives YAML", {
  tmp <- withr::local_tempfile(fileext = ".yaml")
  draft_alternatives(
    x = example_schema(), id = "step-scaling", file_path = tmp, branch = "multi"
  )
  expect_snapshot_file(tmp, "alternatives_template.yaml")

  alts <- read_alternatives(tmp)
  expect_equal(attr(alts, "branch"), "multi")
  expect_equal(alts$overrides, "step-scaling")
  expect_equal(nrow(alts$alternatives[[1]]), 2)
})

test_that("draft_alternatives generates correct single-branch alternatives YAML", {
  tmp <- withr::local_tempfile(fileext = ".yaml")
  draft_alternatives(
    x = example_schema(),
    id = c("step-scaling", "step-education"),
    file_path = tmp,
    branch = "single"
  )
  expect_snapshot_file(tmp, "alternatives_template_single.yaml")

  alts <- read_alternatives(tmp)
  expect_equal(attr(alts, "branch"), "single")
  expect_equal(alts$overrides, c("step-scaling", "step-education"))
  expect_true(all(vapply(alts$alternatives, nrow, integer(1)) == 1))
})

test_that("draft_alternatives errors on an unknown step id", {
  schema <- example_schema()
  expect_error(
    draft_alternatives(schema, id = "does-not-exist", branch = "multi"),
    "not found"
  )
})

test_that("draft_alternatives requires branch to be specified", {
  schema <- example_schema()
  expect_error(
    draft_alternatives(schema, id = "step-scaling"),
    "branch"
  )
})
