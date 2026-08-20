test_that("plot work", {
  # schema <- example_schema()
  # # plot() and draw_tines() are interchangeable
  # vdiffr::expect_doppelganger("plot with draw-tines", draw_tines(schema))
  # vdiffr::expect_doppelganger("plot with plot", plot(schema))

  # dot_string <- inspect_dot(schema)
  # expect_snapshot(dot_string)


  # multiverse <- example_multiverse()
  # vdiffr::expect_doppelganger("plot for multiverse", draw_tines(schema, index = 2))
})

test_that("tines2dotspec does not error for a schema with no edges", {
  dot_code <- tines:::tines2dotspec(example_schema())

  expect_type(dot_code, "character")
  expect_false(grepl('""', dot_code, fixed = TRUE))
})

test_that("tines2dotspec includes edges when steps share inputs/outputs", {
  dot_code <- tines:::tines2dotspec(example_rdi())

  expect_true(grepl(
    '"step-calc-pet" -> "step-calc-ratio"', dot_code,
    fixed = TRUE
  ))
})
