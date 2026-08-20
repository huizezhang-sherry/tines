# tests/testthat/test-alternatives.R

# Helper function to scrub dynamic dates from files before snapshotting
scrub_date_for_snapshot <- function(file_path) {
  lines <- readLines(file_path)
  # Look for the date string and replace it with a static placeholder
  lines <- sub("date:.*[0-9]{4}-[0-9]{2}-[0-9]{2}.*", "date: YYYY-MM-DD", lines)
  writeLines(lines, file_path)
  return(file_path)
}

test_that("alternative() constructs a valid list and catches missing arguments", {
  # 1. Snapshot the successful creation
  an_alternative <- alternative(
    id = "test-tag",
    fork = "test fork",
    path = "test path",
    rationale = "test rationale"
  )
  expect_snapshot(an_alternative)
  expect_snapshot_error({
    alternative(id = "test-tag")
  })

  alt_obj <- new_alternatives(
    "block-target",
    alternative("tag1", "fork1", "path1", "rationale1")
  )
  expect_snapshot(alt_obj)
})


test_that("read and write with an alternative yaml", {
  tmp_file <- tempfile(fileext = ".yaml")

  write_alternatives(example_alternatives(case = "football"), tmp_file)
  tmp_file <- scrub_date_for_snapshot(tmp_file)
  expect_snapshot_file(tmp_file, name = "alternatives.yaml")
  expect_snapshot({
    read_alternatives(tmp_file)
  })
})
