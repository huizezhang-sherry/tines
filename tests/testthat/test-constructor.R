test_that("schema and multiverse constructor work", {
  schema <- example_schema()
  my_multiverse <- example_multiverse()
  expect_snapshot(schema)
  expect_snapshot(my_multiverse)
})

test_that("get_step_names works for schema and multiverse", {
  expect_equal(
    get_step_names(example_schema()),
    c("step-scaling", "step-education", "step-combine")
  )

  mv_names <- get_step_names(example_multiverse())
  expect_type(mv_names, "list")
  expect_equal(names(mv_names), c("original", "reversed"))
})

test_that("get_step_names errors for unsupported types", {
  expect_error(get_step_names(list()), "Unsupported object type")
})

test_that("validation errors remain stable", {
  schema1 <- build_schema("Valid")
  invalid_schema <- list(a = 1)

  expect_snapshot_error(
    new_multiverse(list(schema1, invalid_schema))
  )
})

test_that("add_step validates its inputs", {
  expect_error(add_step(list(), id = "a"), "object must be of class")

  schema <- build_schema() |> add_step(id = "a")
  expect_error(add_step(schema, id = "a"), "already exists")
})

test_that("add_step defaults NULL inputs/outputs to NA and accepts vectors", {
  schema <- build_schema() |>
    add_step(id = "a") |>
    add_step(id = "b", inputs = c("x", "y"), outputs = "z")

  expect_true(is.na(schema$inputs[[1]]))
  expect_true(is.na(schema$outputs[[1]]))
  expect_equal(schema$inputs[[2]], c("x", "y"))
  expect_equal(schema$outputs[[2]], "z")
})

test_that("add_step preserves name and data attributes across appends", {
  data <- data.frame(x = 1:3)
  schema <- build_schema(name = "Test", data = data) |>
    add_step(id = "a", inputs = "x", outputs = "y")

  expect_equal(attr(schema, "name"), "Test")
  expect_true(has_data(schema))
})

test_that("as_schema coercion methods work as expected", {
  expect_error(as_schema(1), "Cannot coerce")
  expect_error(as_schema(list(a = 1)), "Only a data frame")
  expect_error(as_schema("no/such/file.yml"), "must be a valid file path")

  schema <- example_schema()
  expect_identical(as_schema(schema), schema)
})

test_that("as_schema.list's data.frame branch is unreachable via normal dispatch", {
  # NOTE: as_schema.list() checks is.data.frame(x) internally, but S3 dispatch
  # only reaches `.list` methods when class(x) contains "list" -- which a
  # plain data.frame's class ("data.frame") never does. So a bare data frame
  # actually falls through to as_schema.default() and errors, rather than
  # being coerced. This test documents the current (likely unintended)
  # behavior; see if this should be fixed by adding an as_schema.data.frame
  # method instead.
  df <- as.data.frame(example_schema())
  expect_error(as_schema(df), "Cannot coerce")
})

test_that("as_multiverse coercion methods work as expected", {
  expect_error(as_multiverse(1), "Cannot coerce")

  mv <- example_multiverse()
  expect_identical(as_multiverse(mv), mv)

  schema <- example_schema()
  wrapped <- as_multiverse(schema)
  expect_s3_class(wrapped, "multiverse")
  expect_length(wrapped, 1)
})

test_that("as_multiverse.list flattens nested schemas and multiverses", {
  schema1 <- example_schema()
  schema2 <- example_football()
  mv <- example_multiverse()

  flat <- as_multiverse(list(schema1, mv, list(schema2)))

  expect_s3_class(flat, "multiverse")
  expect_length(flat, 2 + length(mv))
  expect_true(all(vapply(flat, inherits, "schema", FUN.VALUE = logical(1))))
})

test_that("as_multiverse.list errors on elements it cannot coerce", {
  expect_error(
    as_multiverse(list(example_schema(), 1)),
    "cannot be coerced"
  )
})

test_that("build_multiverse auto-names branches from each schema's last step id", {
  named_schema <- build_schema() |> add_step(id = "final-step")
  empty_schema <- build_schema()

  mv <- build_multiverse(named_schema, empty_schema)

  expect_equal(names(mv), c("final-step", "unnamed_path"))
})

test_that("c.schema and c.multiverse combine into a flattened multiverse", {
  schema1 <- example_schema()
  schema2 <- example_football()

  mv <- c(schema1, schema2)
  expect_s3_class(mv, "multiverse")
  expect_length(mv, 2)

  mv2 <- c(mv, schema1)
  expect_s3_class(mv2, "multiverse")
  expect_length(mv2, 3)
})

test_that("print methods remain stable (snapshot)", {
  expect_snapshot(print(build_schema()))
  expect_snapshot(print(new_multiverse(list())))
  expect_snapshot(print(build_multiverse(only_branch = example_schema())))
})

test_that("tbl_sum.schema reflects the name attribute", {
  expect_equal(pillar::tbl_sum(build_schema(name = "X")), c("A schema" = "X"))
  expect_equal(pillar::tbl_sum(build_schema()), c("A schema" = "0 x 7"))
})
