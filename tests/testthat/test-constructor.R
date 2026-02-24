test_that("schema and multiverse constructor work", {

  schema <- example_schema()
  my_multiverse <- example_multiverse()
  expect_snapshot(schema)
  expect_snapshot(my_multiverse)
})

test_that("validation errors remain stable", {
  schema1 <- build_schema("Valid")
  invalid_schema <- list(a = 1)

  expect_snapshot_error(
    new_multiverse(list(schema1, invalid_schema))
  )
})
