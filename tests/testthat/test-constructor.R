test_that("schema and multiverse constructor work", {

  schema <- build_schema("HDI Example") |>
    add_block(tag = "block-scaling",
              type = "constraint",
              action = "variables are in different scales",
              decision = "apply min-max scaling to each variable",
              justification = "to put them on the same scale for combination",
              solves = "block-combine",
              feeds = "block-education") |>
    add_block(tag = "block-education",
              type = "step",
              action = "combine the school variables into one dimension",
              decision = "average exp sch and avg sch",
              justification = "the most intuitive way",
              feeds = "block-combine") |>
    add_block(tag = "block-combine",
              type = "step",
              action = "combine the three dimensions into a single index",
              decision = "use the geometric mean",
              justification = "the geometric mean is more appropriate than arithmetic mean")

  schema2 <- build_schema("HDI Example") |>
    add_block(tag = "block-education",
              type = "step",
              action = "combine the school variables into one dimension",
              decision = "average exp sch and avg sch",
              justification = "the most intuitive way",
              feeds = "block-scaling") |>
    add_block(tag = "block-scaling",
              type = "constraint",
              action = "variables are in different scales",
              decision = "apply min-max scaling to each variable",
              justification = "to put them on the same scale for combination",
              solves = "block-combine",
              feeds = "block-combine") |>
    add_block(tag = "block-combine",
              type = "step",
              action = "combine the three dimensions into a single index",
              decision = "use the geometric mean",
              justification = "the geometric mean is more appropriate than arithmetic mean")

  my_multiverse <- build_multiverse(original = schema, reversed = schema2)


  expect_snapshot(str(schema))
  expect_snapshot(str(schema2))
  expect_snapshot(str(my_multiverse))
})

test_that("validation errors remain stable", {
  schema1 <- build_schema("Valid")
  invalid_schema <- list(a = 1)

  expect_snapshot_error(
    new_multiverse(list(schema1, invalid_schema))
  )
})
