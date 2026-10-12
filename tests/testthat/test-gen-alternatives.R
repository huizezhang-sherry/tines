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
  base_schema <- example_football_grp5()
  alts <- example_football_grp5_alternatives()
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
  base_schema <- example_hdi()
  alts <- example_football_grp5_alternatives()
  expect_snapshot_error({
    expand_tines(base_schema, alts)
  })

  # a multiverse is not expandable: one alternatives file with `branch: multi`
  # is the way to vary several steps at once
  expect_snapshot_error({
    expand_tines(example_hdi_multiverse(), example_hdi_alternatives())
  })
})

test_that("expand_tines preserves each step's id (does not rename it to the alternative's id)", {
  base_schema <- example_football_grp5()
  alts <- example_football_grp5_alternatives()
  target <- alts$overrides

  mv <- expand_tines(base_schema, alts)
  for (branch_name in setdiff(names(mv), "original")) {
    branch <- mv[[branch_name]]
    expect_true(target %in% branch$id)
    expect_false(branch_name %in% branch$id)
  }
})

test_that("a target step absent from the base schema is an authoring error", {
  base_schema <- example_hdi()
  alts <- new_alternatives(
    node(overrides = "does-not-exist", alternative(id = "a1", decision = "d", rationale = "r")),
    branch = "multi"
  )
  expect_error(expand_tines(base_schema, alts), "not found in the base schema")
})

test_that("expand_tines() re-validates branch = 'single' even if the object was built or mutated by hand", {
  base_schema <- example_hdi()
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

test_that("an overridden step takes the alternative's I/O, or is left unset", {
  base <- build_schema() |>
    add_step(id = "a", decision = "average r1 and r2", inputs = c("r1", "r2"), outputs = "x") |>
    add_step(id = "b", decision = "model", inputs = "x", outputs = "fit")

  alts <- new_alternatives(
    node(
      overrides = "a",
      alternative("a-r1", "use r1 only", "fewer raters"),
      alternative("a-max", "take the max", "robust", inputs = c("r1", "r2"), outputs = "x")
    ),
    branch = "multi"
  )
  expect_message(mv <- expand_tines(base, alts), "1 branch has an incomplete mapping")

  expect_equal(mv$original$inputs[[1]], c("r1", "r2"))
  expect_equal(mv$`a-max`$inputs[[1]], c("r1", "r2"))
  # steps the alternative did not touch keep theirs
  expect_equal(mv$`a-max`$inputs[[2]], "x")
  # the original step's I/O is not carried over: the step is left unset
  expect_equal(tines:::unmapped_steps(mv$`a-r1`), "a")
  expect_equal(mv$`a-r1`$inputs[[2]], "x")
})

test_that("expand_tines() carries the data reference to every branch", {
  base <- update_data(example_hdi(), "datasets::mtcars")
  mv <- expand_tines(base, example_hdi_alternatives())
  for (branch in mv) expect_equal(attr(branch, "data")$source, "datasets::mtcars")
})

test_that("alternative I/O survives a write/read round trip", {
  alts <- new_alternatives(
    node(overrides = "a", alternative("a1", "d", "r", inputs = "r1", outputs = character(0))),
    branch = "multi"
  )
  path <- withr::local_tempfile(fileext = ".yml")
  write_alternatives(alts, path)
  back <- read_alternatives(path)
  expect_equal(back$alternatives[[1]]$inputs[[1]], "r1")
  expect_equal(back$alternatives[[1]]$outputs[[1]], character(0))
})
