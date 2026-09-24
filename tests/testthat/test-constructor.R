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
  expect_identical(as_schema(example_schema()), example_schema())
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

test_that("a multiverse follows list conventions for names", {
  s1 <- example_schema()
  s2 <- example_football()

  # names supplied are kept
  expect_equal(names(as_multiverse(list(hdi = s1, football = s2))), c("hdi", "football"))

  # none supplied: none are invented
  expect_null(names(as_multiverse(list(s1, s2))))
  expect_null(names(as_multiverse(s1)))

  # partly named stays partly named, as a plain list would
  expect_equal(names(as_multiverse(list(hdi = s1, s2))), c("hdi", ""))

  # nested multiverses contribute the names their own branches had
  inner <- as_multiverse(list(hdi = s1))
  expect_equal(names(as_multiverse(list(inner, football = s2))), c("hdi", "football"))
})

test_that("gen_code() derives a usable file name for every branch", {
  s <- build_schema() |> add_step(id = "a", objective = "o", decision = "d")
  two <- rep(list(s), 2)

  # unnamed branches fall back to their position
  expect_equal(tines:::multiverse_file_ids(two), c("branch_01", "branch_02"))

  # a blank name among named ones also falls back, rather than yielding ".R"
  names(two) <- c("alpha", "")
  expect_equal(tines:::multiverse_file_ids(two), c("alpha", "branch_02"))

  # two branches sharing a name must not overwrite each other's script
  names(two) <- c("dup", "dup")
  expect_equal(tines:::multiverse_file_ids(two), c("dup", "dup_1"))

  # characters that are unsafe in a file name are replaced
  names(two) <- c("branch one!", "b")
  expect_equal(tines:::multiverse_file_ids(two), c("branch_one", "b"))
})

test_that("as_multiverse flattens nested multiverses, keeping their branch names", {
  inner <- as_multiverse(list(hdi = example_schema()))
  flat <- as_multiverse(list(inner, football = example_football()))

  expect_s3_class(flat, "multiverse")
  expect_equal(names(flat), c("hdi", "football"))
})

test_that("as_schema() coerces a data frame of steps", {
  df <- data.frame(
    id = c("step-clean", "step-model"),
    objective = c("handle missing values", "estimate the effect"),
    decision = c("drop incomplete cases", "fit a linear model"),
    rationale = c("keeps it simple", "the effect is assumed linear")
  )

  schema <- as_schema(df, name = "from a spreadsheet")
  expect_s3_class(schema, "schema")
  expect_s3_class(schema, "tbl_df")
  expect_equal(nrow(schema), 2)
  expect_equal(attr(schema, "name"), "from a spreadsheet")

  # a data frame that is missing required columns says which ones
  expect_error(as_schema(df[, c("id", "decision")]), "objective")
})

test_that("expand_tines() rejects a multiverse with a pointer to the right approach", {
  mv <- as_multiverse(list(hdi = example_schema()))
  expect_error(
    expand_tines(mv, example_alternatives(case = "hdi")),
    "not a"
  )
})

test_that("print methods remain stable (snapshot)", {
  expect_snapshot(print(build_schema()))
  expect_snapshot(print(new_multiverse(list())))
  expect_snapshot(print(as_multiverse(list(only_branch = example_schema()))))
})

test_that("tbl_sum.schema reflects the name attribute", {
  expect_equal(pillar::tbl_sum(build_schema(name = "X")), c("A schema" = "X"))
  expect_equal(pillar::tbl_sum(build_schema()), c("A schema" = "0 x 6"))
})

test_that("add_step() works on schemas whose columns differ from the canonical set", {
  # A schema read from a YAML file carries only the fields that file
  # declared, so its columns need not match the ones add_step() builds.
  # This used to fail outright under rbind().
  from_file <- read_tines(system.file("hdi.yml", package = "tines"))
  expect_false("source_schema" %in% names(from_file))

  added <- add_step(
    from_file,
    id = "step-new", objective = "o", decision = "d", rationale = "r"
  )
  expect_s3_class(added, "schema")
  expect_equal(nrow(added), nrow(from_file) + 1)
  expect_equal(attr(added, "name"), attr(from_file, "name"))

  # An all-NA source_schema column is not introduced where it wasn't used
  expect_false("source_schema" %in% names(added))

  # ...but a schema composed through the internal import_step() does carry
  # the column, and add_step() lines up against it instead of widening it
  composed <- tines:::import_step(
    build_schema(), source_schema = example_schema(),
    source_schema_name = "other_schema", id = "step-scaling"
  )
  expect_equal(composed$source_schema, "other_schema")
  grown_composed <- add_step(composed, id = "extra", objective = "o", decision = "d")
  expect_equal(grown_composed$source_schema, c("other_schema", NA))

  # Extra fields carried by LLM-drafted schemas survive, NA for the new step
  drafted <- example_football_grp20()
  expect_true("confidence" %in% names(drafted))
  grown <- add_step(drafted, id = "step-new", objective = "o", decision = "d")
  expect_equal(nrow(grown), nrow(drafted) + 1)
  expect_true(is.na(grown$confidence[nrow(grown)]))
})
