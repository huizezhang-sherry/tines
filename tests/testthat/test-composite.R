test_that("import_step appends a row from another schema", {
  source_schema <- build_schema() |>
    add_step(
      id = "step-source",
      objective = "do something",
      decision = "the chosen approach",
      rationale = "because reasons",
      inputs = "x",
      outputs = "y"
    )

  schema <- build_schema() |>
    tines:::import_step(
      source_schema = source_schema,
      source_schema_name = "source_schema",
      id = "step-source"
    )

  expect_s3_class(schema, "schema")
  expect_equal(nrow(schema), 1)
  expect_equal(schema$id, "step-source")
  expect_equal(schema$decision, "the chosen approach")
  expect_equal(schema$source_schema, "source_schema")
})

test_that("import_step appends to an existing schema and applies overrides", {
  source_schema <- build_schema() |>
    add_step(
      id = "step-source",
      objective = "do something",
      decision = "the chosen approach",
      rationale = "because reasons",
      inputs = "x",
      outputs = "y"
    )

  schema <- build_schema() |>
    add_step(
      id = "step-first", objective = "a", decision = "b", rationale = "c"
    ) |>
    tines:::import_step(
      source_schema = source_schema,
      id = "step-source",
      inputs = "z"
    )

  expect_equal(nrow(schema), 2)
  expect_equal(schema$id, c("step-first", "step-source"))
  expect_equal(schema$inputs[[2]], "z")
})

test_that("import_step errors when the id is not found", {
  source_schema <- build_schema() |>
    add_step(
      id = "step-source", objective = "a", decision = "b", rationale = "c"
    )

  expect_error(
    build_schema() |>
      tines:::import_step(source_schema = source_schema, id = "missing-id"),
    "Could not find step"
  )
})

test_that("example_rdi builds a composite schema, not an edge data frame", {
  schema <- tines:::example_rdi()

  expect_s3_class(schema, "schema")
  expect_true(
    all(c("id", "objective", "decision", "rationale") %in% names(schema))
  )
  expect_equal(
    schema$source_schema,
    c("spei_template", NA, "spi_template", NA, NA)
  )
})
