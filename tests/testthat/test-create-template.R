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

test_that("draft_alternatives generates correct alternatives YAML", {
  tmp <- withr::local_tempfile(fileext = ".yaml")
  draft_alternatives(
    x = example_schema(), id = "step-scaling", file_path = tmp
  )
  expect_snapshot_file(tmp, "alternatives_template.yaml")
})
