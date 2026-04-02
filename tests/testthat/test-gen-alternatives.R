test_that("prompt_alternatives wording remains stable (snapshot)", {
  expect_snapshot({prompt_alternatives(step = "clean-missing-data", print = FALSE)})
  expect_snapshot({prompt_alternatives(step = "my-target-block", n = 2, print = FALSE)})
  expect_snapshot({prompt_alternatives(step = "my-target-block", print = TRUE)})

})



test_that("expand_tines", {

  # expand on a schema
  base_schema <- example_football()
  alts <- example_alternatives(case = "football")
  expect_snapshot({expand_tines(base_schema, alts)})

  # write the alternatives to a temporary file
  tmp_file <- tempfile(fileext = ".yaml")
  write_alternatives(alts, tmp_file)
  expect_snapshot({expand_tines(base_schema, tmp_file)})

  # error if there is no matching block
  base_schema <- example_schema()
  alts <- example_alternatives(case = "football")
  expect_snapshot_error({expand_tines(base_schema, alts)})

  # expand on the multiverse
  multiverse <- example_multiverse()
  alts <- example_alternatives(case = "hdi")
  expect_snapshot({expand_tines(multiverse, alts)})



})

