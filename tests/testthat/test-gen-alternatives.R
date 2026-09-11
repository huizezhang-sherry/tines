test_that("prompt_alternatives wording remains stable (snapshot)", {
  expect_snapshot({
    prompt_alternatives(step = "clean-missing-data", print = FALSE)
  })
  expect_snapshot({
    prompt_alternatives(step = "my-target-block", n = 2, print = FALSE)
  })
  expect_snapshot({
    prompt_alternatives(step = "my-target-block", print = TRUE)
  })
})



test_that("expand_tines", {
  # expand on a schema
  base_schema <- example_football()
  alts <- example_alternatives(case = "football")
  expect_snapshot({
    expand_tines(base_schema, alts)
  })

  # write the alternatives to a temporary file
  tmp_file <- tempfile(fileext = ".yaml")
  write_alternatives(alts, tmp_file)
  expect_snapshot({
    expand_tines(base_schema, tmp_file)
  })

  # error if there is no matching step
  base_schema <- example_schema()
  alts <- example_alternatives(case = "football")
  expect_snapshot_error({
    expand_tines(base_schema, alts)
  })

  # expand on the multiverse
  multiverse <- example_multiverse()
  alts <- example_alternatives(case = "hdi")
  expect_snapshot({
    expand_tines(multiverse, alts)
  })
})

test_that("expand_tines preserves each step's id (does not rename it to the alternative's id)", {
  base_schema <- example_football()
  alts <- example_alternatives(case = "football")
  target <- alts$overrides

  mv <- expand_tines(base_schema, alts)
  for (branch_name in setdiff(names(mv), "original")) {
    branch <- mv[[branch_name]]
    expect_true(target %in% branch$id)
    expect_false(branch_name %in% branch$id)
  }
})

test_that("a target step absent from the base schema is an authoring error", {
  base_schema <- example_schema()
  alts <- new_alternatives(
    node(overrides = "does-not-exist", alternative(id = "a1", decision = "d", rationale = "r")),
    branch = "multi"
  )
  expect_error(expand_tines(base_schema, alts), "not found in the base schema")
})

test_that("expand_tines() re-validates branch = 'single' even if the object was built or mutated by hand", {
  base_schema <- example_schema()
  alts <- new_alternatives(
    node(overrides = "step-scaling", alternative(id = "a1", decision = "d1", rationale = "r1")),
    branch = "single"
  )
  # Bypass new_alternatives()'s own validation by mutating the node directly.
  alts$alternatives[[1]] <- rbind(
    alts$alternatives[[1]],
    tibble::tibble(id = "a2", decision = "d2", rationale = "r2")
  )
  expect_error(expand_tines(base_schema, alts), "exactly one alternative")
})
