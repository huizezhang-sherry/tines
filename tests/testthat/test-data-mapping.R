hdi_data <- data.frame(life_exp = c(72, 81), exp_sch = c(13, 16), gni = c(9000, 42000))

mapped_hdi <- function(data = hdi_data) {
  build_schema("HDI", data = data) |>
    add_step(
      id = "step-scaling", decision = "apply min-max scaling",
      inputs = c("life_exp", "exp_sch", "gni"), outputs = "scaled"
    ) |>
    add_step(
      id = "step-combine", decision = "use the geometric mean",
      inputs = "scaled", outputs = "hdi"
    )
}

test_that("a schema is plain until inputs/outputs are given", {
  plain <- example_hdi()
  expect_false(tines:::is_mapped(plain))
  expect_false(any(c("inputs", "outputs") %in% names(plain)))

  mapped <- mapped_hdi()
  expect_true(tines:::is_mapped(mapped))
  expect_equal(mapped$inputs[[1]], c("life_exp", "exp_sch", "gni"))
  expect_equal(mapped$outputs[[2]], "hdi")
})

test_that("a schema is plain, incomplete, or mapped", {
  expect_false(tines:::has_io(example_hdi()))

  # a step added without I/O to a schema with I/O is left unset
  expect_message(
    incomplete <- add_step(mapped_hdi(), id = "step-report", decision = "print it"),
    "incomplete: step `step-report` has no inputs/outputs"
  )
  expect_true(tines:::has_io(incomplete))
  expect_false(tines:::is_mapped(incomplete))
  expect_equal(tines:::unmapped_steps(incomplete), "step-report")
  expect_match(pillar::tbl_sum(incomplete)[["Mapping"]], "2 of 3")

  # character(0) is a step with none, which completes the mapping
  complete <- add_step(mapped_hdi(), id = "step-report", inputs = "hdi", outputs = character(0))
  expect_true(tines:::is_mapped(complete))
  expect_equal(complete$outputs[[3]], character(0))
})

test_that("a plain schema can be mapped one step at a time", {
  schema <- update_data(example_hdi(), hdi_data)
  expect_message(
    schema <- update_io(schema, "step-scaling", inputs = c("life_exp", "exp_sch", "gni"), outputs = "scaled"),
    "1 of 3 steps mapped"
  )
  expect_message(
    schema <- update_io(schema, "step-education", inputs = "scaled", outputs = "educ"),
    "2 of 3 steps mapped"
  )
  # completing it says so, and from then on the mapping is checked
  expect_message(
    expect_warning(
      schema <- update_io(schema, "step-combine", inputs = "typo", outputs = "hdi"),
      "`typo`"
    ),
    "now has inputs/outputs"
  )
  expect_true(tines:::is_mapped(schema))
})

test_that("an incomplete mapping is not checked", {
  expect_no_warning(suppressMessages(
    update_io(update_data(example_hdi(), hdi_data), "step-scaling", inputs = "nowhere", outputs = "x")
  ))
})

test_that("the data reference keeps columns, never the data", {
  ref <- attr(mapped_hdi(), "data")
  expect_named(ref, c("source", "object", "columns"))
  # a data frame leaves no reference that can be written down
  expect_null(ref$source)
  expect_equal(ref$columns$name, names(hdi_data))
})

test_that("a broken input is reported once, where it is introduced", {
  expect_warning(
    s <- build_schema(data = hdi_data) |>
      add_step(id = "a", inputs = "life_exp", outputs = "x") |>
      add_step(id = "b", inputs = "typo", outputs = "y") |>
      add_step(id = "c", inputs = "y", outputs = "z"),
    "`typo`"
  )
  # a later, clean step does not repeat the earlier problem
  expect_no_warning(add_step(s, id = "d", inputs = "z", outputs = "w"))
})

test_that("update_io() flags a renamed output that a later step still reads", {
  schema <- mapped_hdi()
  expect_warning(
    renamed <- update_io(schema, "step-scaling", outputs = "df_scaled"),
    "reads `scaled`"
  )
  expect_no_warning(update_io(renamed, "step-combine", inputs = "df_scaled"))

  # NULL leaves a field alone; the attributes survive the edit
  kept <- update_io(schema, "step-combine", outputs = "index")
  expect_equal(kept$inputs[[2]], "scaled")
  expect_equal(attr(kept, "name"), "HDI")
  expect_equal(attr(kept, "data"), attr(schema, "data"))

  expect_error(update_io(schema, "no-such-step", inputs = "x"), "not found")
})

test_that("update_data() warns, rather than refuses, when columns do not match", {
  renamed <- data.frame(life_exp = 1, exp_sch = 2, income = 3)
  expect_warning(s <- update_data(mapped_hdi(), renamed), "`gni`")
  expect_equal(attr(s, "data")$columns$name, names(renamed))
})

test_that("validate_schema() catches edits made directly on the tibble", {
  schema <- mapped_hdi()
  schema$inputs[[2]] <- "nowhere"
  expect_warning(validate_schema(schema), "`nowhere`")
})

test_that("validate_schema() reports read-before-created and duplicate outputs", {
  schema <- mapped_hdi()
  schema$inputs[[1]] <- "hdi"
  expect_warning(validate_schema(schema), "only created later")

  schema <- mapped_hdi()
  schema$outputs[[2]] <- "scaled"
  expect_warning(validate_schema(schema), "more than one step")
})

test_that("a direct edit that unsets a step makes the mapping incomplete", {
  schema <- mapped_hdi()
  schema$inputs[2] <- list(NULL)
  expect_message(validate_schema(schema), "incomplete")

  # one column without the other is malformed
  schema <- mapped_hdi()
  schema$outputs <- NULL
  expect_error(validate_schema(schema), "needs both")
})

test_that("structural problems are errors", {
  schema <- mapped_hdi()
  schema$id[2] <- "step-scaling"
  expect_error(validate_schema(schema), "more than once")

  expect_error(validate_schema(example_hdi()[, c("id", "decision")]), "objective")
})

test_that("a data source is looked up by kind", {
  csv <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(hdi_data, csv, row.names = FALSE)
  cols <- tines:::source_columns(csv)
  expect_equal(cols$name, names(hdi_data))
  expect_equal(cols$type, rep("numeric", 3))

  rds <- withr::local_tempfile(fileext = ".rds")
  saveRDS(hdi_data, rds)
  expect_equal(tines:::source_columns(rds)$name, names(hdi_data))

  expect_equal(tines:::source_columns("datasets::mtcars")$name, names(mtcars))

  script <- withr::local_tempfile(fileext = ".R")
  writeLines(c("x <- 1", "df <- data.frame(a = 1, b = 'z')"), script)
  expect_equal(tines:::source_columns(script)$name, c("a", "b"))

  two <- withr::local_tempfile(fileext = ".R")
  writeLines(c("a <- data.frame(x = 1)", "b <- data.frame(y = 1)"), two)
  expect_error(tines:::source_columns(two), "object")
  expect_equal(tines:::source_columns(two, object = "b")$name, "y")
})

test_that("gen_io() needs data to map against", {
  expect_error(gen_io(example_hdi()), "needs the data")
})

test_that("gen_io() matches the LLM's reply to steps by id", {
  reply <- paste(
    "nodes:",
    "- id: step-combine",
    "  inputs: [scaled]",
    "  outputs: [hdi]",
    "- id: step-scaling",
    "  inputs: [life_exp, exp_sch, gni]",
    "  outputs: [scaled]",
    sep = "\n"
  )
  local_mocked_bindings(
    chat = function(...) list(chat = function(prompt) reply),
    .package = "ellmer"
  )
  schema <- build_schema() |>
    add_step(id = "step-scaling", decision = "scale") |>
    add_step(id = "step-combine", decision = "combine")

  mapped <- suppressMessages(gen_io(schema, data = hdi_data))
  expect_equal(mapped$inputs[[1]], c("life_exp", "exp_sch", "gni"))
  expect_equal(mapped$outputs[[2]], "hdi")
  expect_equal(attr(mapped, "data")$columns$name, names(hdi_data))
})

test_that("gen_io() leaves a step the reply skips unset", {
  local_mocked_bindings(
    chat = function(...) list(chat = function(prompt) "nodes:\n- id: step-scaling\n  inputs: [gni]\n  outputs: [x]"),
    .package = "ellmer"
  )
  schema <- build_schema() |>
    add_step(id = "step-scaling", decision = "scale") |>
    add_step(id = "step-combine", decision = "combine")
  mapped <- suppressMessages(gen_io(schema, data = hdi_data))
  expect_equal(tines:::unmapped_steps(mapped), "step-combine")
})
