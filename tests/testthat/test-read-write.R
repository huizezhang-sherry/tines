test_that("read and write", {

  # work for singles
  schema <- example_schema()
  temp_path <- withr::local_tempfile(fileext = ".yaml")
  write_tines(schema, temp_path)
  schema_read <- read_tines(temp_path)
  expect_snapshot_file(temp_path, name = "schema.yaml")
  expect_snapshot(schema_read)

  # additional arguments are passed to yaml::write_yaml
  write_tines(schema, temp_path, indent = 4)
  expect_snapshot_file(temp_path, name = "schema-indented.yaml")

  # work for multiverse
  my_multiverse <- example_multiverse()
  temp_path <- withr::local_tempfile(fileext = ".yaml")
  write_tines(my_multiverse, temp_path)
  multiverse_read <- read_tines(temp_path)

  expect_snapshot_file(temp_path, name = "multiverse.yaml")
  expect_snapshot(multiverse_read)

})
