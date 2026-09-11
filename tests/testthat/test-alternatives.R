# tests/testthat/test-alternatives.R

# Helper function to scrub dynamic dates from files before snapshotting
scrub_date_for_snapshot <- function(file_path) {
  lines <- readLines(file_path)
  # Look for the date string and replace it with a static placeholder
  lines <- sub("date:.*[0-9]{4}-[0-9]{2}-[0-9]{2}.*", "date: YYYY-MM-DD", lines)
  writeLines(lines, file_path)
  return(file_path)
}

test_that("alternative() constructs a valid list and catches missing arguments", {
  an_alternative <- alternative(
    id = "test-tag",
    decision = "test decision",
    rationale = "test rationale"
  )
  expect_snapshot(an_alternative)
  expect_snapshot_error({
    alternative(id = "test-tag")
  })
})

test_that("node() bundles alternatives under one step and catches missing arguments", {
  a_node <- node(
    overrides = "step-scaling",
    alternative("tag1", "decision1", "rationale1")
  )
  expect_equal(a_node$overrides, "step-scaling")
  expect_named(a_node$alternatives, c("id", "decision", "rationale"))

  expect_snapshot_error({
    node(overrides = "step-scaling")
  })
})

test_that("branch = 'multi' expands one node into independent branches", {
  alts <- new_alternatives(
    node(
      overrides = "step-combine",
      alternative(id = "a1", decision = "d1", rationale = "r1"),
      alternative(id = "a2", decision = "d2", rationale = "r2"),
      alternative(id = "a3", decision = "d3", rationale = "r3")
    ),
    branch = "multi"
  )
  expect_s3_class(alts, "alternatives")
  expect_equal(attr(alts, "branch"), "multi")
  expect_snapshot(alts)

  base_schema <- example_schema()
  mv <- expand_tines(base_schema, alts)
  expect_named(mv, c("original", "a1", "a2", "a3"))
})

test_that("branch = 'single' combines all nodes' (sole) alternative into one branch", {
  alts <- new_alternatives(
    node(overrides = "step-scaling", alternative(id = "s1", decision = "ds1", rationale = "rs1")),
    node(overrides = "step-education", alternative(id = "e1", decision = "de1", rationale = "re1")),
    branch = "single"
  )
  expect_equal(attr(alts, "branch"), "single")

  base_schema <- example_schema()
  mv <- expand_tines(base_schema, alts)
  expect_named(mv, c("original", "s1+e1"))
  expect_equal(
    mv$`s1+e1`$decision[mv$`s1+e1`$id == "step-scaling"],
    "ds1"
  )
  expect_equal(
    mv$`s1+e1`$decision[mv$`s1+e1`$id == "step-education"],
    "de1"
  )
})

test_that("branch = 'single' requires exactly one alternative per node", {
  expect_snapshot_error({
    new_alternatives(
      node(
        overrides = "step-scaling",
        alternative(id = "s1", decision = "ds1", rationale = "rs1"),
        alternative(id = "s2", decision = "ds2", rationale = "rs2")
      ),
      branch = "single"
    )
  })
})

test_that("branch = 'multi' crosses multiple nodes into the full factorial, including 'keep original'", {
  base_schema <- example_schema()

  # 2 nodes, 1 alternative each -> 2x2 = 4 (original, node-1-only, node-2-only, both)
  alts <- new_alternatives(
    node(overrides = "step-scaling", alternative(id = "s1", decision = "ds1", rationale = "rs1")),
    node(overrides = "step-education", alternative(id = "e1", decision = "de1", rationale = "re1")),
    branch = "multi"
  )
  mv <- expand_tines(base_schema, alts)
  expect_named(mv, c("original", "s1", "e1", "s1+e1"), ignore.order = TRUE)
  expect_length(mv, 4)

  # 2 nodes, 3 alternatives each -> (3+1) x (3+1) = 16
  alts2 <- new_alternatives(
    node(
      overrides = "step-scaling",
      alternative(id = "s1", decision = "ds1", rationale = "rs1"),
      alternative(id = "s2", decision = "ds2", rationale = "rs2"),
      alternative(id = "s3", decision = "ds3", rationale = "rs3")
    ),
    node(
      overrides = "step-education",
      alternative(id = "e1", decision = "de1", rationale = "re1"),
      alternative(id = "e2", decision = "de2", rationale = "re2"),
      alternative(id = "e3", decision = "de3", rationale = "re3")
    ),
    branch = "multi"
  )
  mv2 <- expand_tines(base_schema, alts2)
  expect_length(mv2, 16)
})

test_that("expand_tines() errors when a node's step is not in the base schema", {
  alts <- new_alternatives(
    node(overrides = "does-not-exist", alternative(id = "a1", decision = "d1", rationale = "r1")),
    branch = "multi"
  )
  expect_error(expand_tines(example_schema(), alts), "not found in the base schema")
})

test_that("new_alternatives() requires branch to be specified", {
  expect_error(
    new_alternatives(
      node(overrides = "step-combine", alternative(id = "a1", decision = "d1", rationale = "r1"))
    ),
    "branch"
  )
})

test_that("read and write with an alternative yaml", {
  tmp_file <- tempfile(fileext = ".yaml")

  write_alternatives(example_alternatives(case = "football"), tmp_file)
  tmp_file <- scrub_date_for_snapshot(tmp_file)
  expect_snapshot_file(tmp_file, name = "alternatives.yaml")
  expect_snapshot({
    read_alternatives(tmp_file)
  })
})

test_that("write_alternatives()/read_alternatives() round-trip both branch modes", {
  alts_multi <- new_alternatives(
    node(
      overrides = "step-combine",
      alternative(id = "step-weighted-mean", decision = "use a weighted mean", rationale = "down-weights noisier dimensions")
    ),
    branch = "multi"
  )
  out_multi <- withr::local_tempfile(fileext = ".yaml")
  write_alternatives(alts_multi, out_multi)
  expect_identical(alts_multi, read_alternatives(out_multi))

  alts_single <- new_alternatives(
    node(overrides = "step-scaling", alternative(id = "s1", decision = "ds1", rationale = "rs1")),
    node(overrides = "step-education", alternative(id = "e1", decision = "de1", rationale = "re1")),
    branch = "single"
  )
  out_single <- withr::local_tempfile(fileext = ".yaml")
  write_alternatives(alts_single, out_single)
  expect_identical(alts_single, read_alternatives(out_single))
})

test_that("read_alternatives() requires meta.branch to be declared and valid", {
  bad_file <- withr::local_tempfile(fileext = ".yaml")
  yaml::write_yaml(
    list(
      meta = list(type = "alternatives"),
      nodes = list(list(overrides = "step-combine", alternatives = list(list(id = "a1", decision = "d1", rationale = "r1"))))
    ),
    bad_file
  )
  expect_error(read_alternatives(bad_file), "meta.branch")
})

test_that("read_alternatives() errors if branch: single but a node has more than one alternative", {
  bad_file <- withr::local_tempfile(fileext = ".yaml")
  yaml::write_yaml(
    list(
      meta = list(type = "alternatives", branch = "single"),
      nodes = list(list(
        overrides = "step-combine",
        alternatives = list(
          list(id = "a1", decision = "d1", rationale = "r1"),
          list(id = "a2", decision = "d2", rationale = "r2")
        )
      ))
    ),
    bad_file
  )
  expect_error(read_alternatives(bad_file), "exactly one alternative")
})
