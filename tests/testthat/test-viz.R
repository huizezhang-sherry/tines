test_that("plot work", {
  # schema <- example_hdi()
  # # plot() and draw_tines() are interchangeable
  # vdiffr::expect_doppelganger("plot with draw-tines", draw_tines(schema))
  # vdiffr::expect_doppelganger("plot with plot", plot(schema))

  # dot_string <- inspect_dot(schema)
  # expect_snapshot(dot_string)


  # multiverse <- example_hdi_multiverse()
  # vdiffr::expect_doppelganger("plot for multiverse", draw_tines(schema, index = 2))
})

test_that("tines2dotspec does not error for a schema with no edges", {
  dot_code <- tines:::tines2dotspec(example_hdi())

  expect_type(dot_code, "character")
  expect_false(grepl('""', dot_code, fixed = TRUE))
})

test_that("tines2dotspec includes edges when steps share inputs/outputs", {
  dot_code <- tines:::tines2dotspec(tines:::example_rdi())

  expect_true(grepl(
    '"step-calc-pet" -> "step-calc-ratio"', dot_code,
    fixed = TRUE
  ))
})

test_that("generate_edges links steps by matching outputs to inputs", {
  schema <- build_schema() |>
    add_step(
      id = "step-a", objective = "a", decision = "a", rationale = "a",
      inputs = character(0), outputs = "x"
    ) |>
    add_step(
      id = "step-b", objective = "b", decision = "b", rationale = "b",
      inputs = "x", outputs = "y"
    ) |>
    add_step(
      id = "step-c", objective = "c", decision = "c", rationale = "c",
      inputs = "y", outputs = character(0)
    )

  edges <- tines:::generate_edges(schema)

  expect_s3_class(edges, "data.frame")
  expect_false(inherits(edges, "schema"))
  expect_equal(edges$from, c("step-a", "step-b"))
  expect_equal(edges$to, c("step-b", "step-c"))
  expect_equal(edges$style, c("solid", "solid"))
})

test_that("a plain schema is drawn as a dashed chain", {
  edges <- tines:::generate_edges(example_hdi())
  expect_equal(edges$from, c("step-scaling", "step-education"))
  expect_equal(edges$to, c("step-education", "step-combine"))
  expect_equal(unique(edges$style), "dashed")
})

test_that("mapped steps that share no variables are not joined", {
  schema <- build_schema() |>
    add_step(id = "a", inputs = "x", outputs = "x1") |>
    add_step(id = "b", inputs = "y", outputs = "y1") |>
    add_step(id = "c", inputs = c("x1", "y1"), outputs = "z")
  edges <- tines:::generate_edges(schema)
  expect_equal(paste(edges$from, edges$to), c("a c", "b c"))
})

test_that("generate_edges returns no rows for a single step", {
  schema <- build_schema() |>
    add_step(id = "step-a", objective = "a", decision = "a", rationale = "a")

  edges <- tines:::generate_edges(schema)
  expect_equal(nrow(edges), 0)
})
