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
  schema <- example_schema()
  temp_path <- withr::local_tempfile(fileext = ".yaml")
  write_tines(schema, temp_path)
  schema_read <- read_tines(temp_path)
  expect_snapshot_file(temp_path, name = "schema.yaml")
  expect_snapshot(schema_read)

  # additional arguments are passed to yaml::write_yaml
  write_tines(schema, temp_path, indent = 4)
  temp_path <- scrub_date_for_snapshot(temp_path)
  expect_snapshot_file(temp_path, name = "schema-indented.yaml")

  # work for multiverse
  my_multiverse <- example_multiverse()
  temp_path <- withr::local_tempfile(fileext = ".yaml")
  write_tines(my_multiverse, temp_path)
  temp_path <- scrub_date_for_snapshot(temp_path)
  multiverse_read <- read_tines(temp_path)

  expect_snapshot_file(temp_path, name = "multiverse.yaml")
  expect_snapshot(multiverse_read)

})
