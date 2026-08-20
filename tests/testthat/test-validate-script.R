test_that("scan_file_system_commands flags dangerous scripts", {
  dangerous <- withr::local_tempfile(fileext = ".R")
  writeLines(c("x <- 1", "unlink('some/path', recursive = TRUE)"), dangerous)
  expect_error(scan_file_system_commands(dangerous), "SECURITY ALERT")

  dangerous2 <- withr::local_tempfile(fileext = ".R")
  writeLines("system('rm -rf /')", dangerous2)
  expect_error(scan_file_system_commands(dangerous2), "SECURITY ALERT")
})

test_that("scan_file_system_commands allows safe scripts", {
  safe <- withr::local_tempfile(fileext = ".R")
  writeLines(c("x <- 1", "y <- x + 1", "df <- data.frame(a = 1:3)"), safe)
  expect_no_error(scan_file_system_commands(safe))
})

test_that("build_sys_prompt wording remains stable (snapshot)", {
  expect_snapshot(cat(build_sys_prompt(NULL)))
  expect_snapshot(cat(build_sys_prompt("data/football.csv")))
})

test_that("execute_in_callr reports success and captures the environment", {
  script <- withr::local_tempfile(fileext = ".R")
  writeLines("x <- 1 + 1", script)
  sandbox_dir <- withr::local_tempdir()

  res <- execute_in_callr(script, sandbox_dir, as_job = FALSE)

  expect_true(res$ok)
  expect_equal(res$data$x, 2)
})

test_that("execute_in_callr reports runtime errors", {
  script <- withr::local_tempfile(fileext = ".R")
  writeLines("stop('boom')", script)
  sandbox_dir <- withr::local_tempdir()

  res <- execute_in_callr(script, sandbox_dir, as_job = FALSE)

  expect_false(res$ok)
  expect_match(res$err_msg, "boom")
})

test_that("execute_in_callr reports syntax errors distinctly", {
  script <- withr::local_tempfile(fileext = ".R")
  writeLines("x <- (1 +", script)
  sandbox_dir <- withr::local_tempdir()

  res <- execute_in_callr(script, sandbox_dir, as_job = FALSE)

  expect_false(res$ok)
  expect_equal(res$bad_line, "Syntax Error (Code could not be parsed)")
})

test_that("setup_sandbox copies the script and an existing data file", {
  script <- withr::local_tempfile(fileext = ".R")
  writeLines("1 + 1", script)
  data_file <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", data_file)

  sandbox <- setup_sandbox(script, data_file)

  expect_true(file.exists(sandbox$script))
  expect_true(file.exists(file.path(sandbox$dir, "data", basename(data_file))))
})

test_that("setup_sandbox warns (not errors) when data file is missing", {
  script <- withr::local_tempfile(fileext = ".R")
  writeLines("1 + 1", script)

  expect_warning(
    sandbox <- setup_sandbox(script, "no/such/file.csv"),
    "not found"
  )
  expect_true(file.exists(sandbox$script))
  expect_false(dir.exists(file.path(sandbox$dir, "data")))
})

test_that("setup_sandbox is a no-op for data when data = NULL", {
  script <- withr::local_tempfile(fileext = ".R")
  writeLines("1 + 1", script)

  sandbox <- setup_sandbox(script, NULL)

  expect_true(file.exists(sandbox$script))
  expect_false(dir.exists(file.path(sandbox$dir, "data")))
})

test_that("save_verbose_iteration writes a numbered copy alongside the original", {
  original <- withr::local_tempfile(fileext = ".R")
  writeLines("1 + 1", original)
  sandbox_script <- withr::local_tempfile(fileext = ".R")
  writeLines("2 + 2", sandbox_script)

  save_verbose_iteration(sandbox_script, original, attempt = 3)

  expected <- file.path(
    dirname(original),
    paste0(tools::file_path_sans_ext(basename(original)), "_iter3.R")
  )
  expect_true(file.exists(expected))
  expect_equal(readLines(expected), "2 + 2")
})

test_that("ask_llm_for_fix strips markdown fences and overwrites the script", {
  fake_chat <- list(chat = function(prompt, echo = FALSE) "```r\nx <- 42\n```")

  sandbox_script <- withr::local_tempfile(fileext = ".R")
  writeLines("x <- 41", sandbox_script)

  ask_llm_for_fix(
    chat = fake_chat,
    sys_prompt = "You are a debugger.",
    sandbox_script = sandbox_script,
    execution_result = list(bad_line = "x <- 41", err_msg = "wrong value")
  )

  expect_equal(readLines(sandbox_script), "x <- 42")
})

test_that("validate_script stops after max_runs when the script never succeeds", {
  local_mocked_bindings(
    execute_in_callr = function(...) list(ok = FALSE, data = NULL, err_msg = "always fails", bad_line = "x")
  )
  local_mocked_bindings(
    chat = function(...) list(chat = function(...) "still broken"),
    .package = "ellmer"
  )

  script <- withr::local_tempfile(fileext = ".R")
  writeLines("stop('fail')", script)

  res <- validate_script(script, max_runs = 2, verbose = FALSE, scan_code = FALSE)

  expect_false(res$success)
  expect_equal(res$file, script)
})

test_that("validate_script succeeds immediately when the script runs cleanly", {
  local_mocked_bindings(
    execute_in_callr = function(...) list(ok = TRUE, data = list(), err_msg = NA, bad_line = NA)
  )
  local_mocked_bindings(
    chat = function(...) list(chat = function(...) cli::cli_abort("should not be called")),
    .package = "ellmer"
  )

  script <- withr::local_tempfile(fileext = ".R")
  writeLines("1 + 1", script)

  res <- validate_script(script, max_runs = 2, verbose = FALSE, scan_code = FALSE)

  expect_true(res$success)
})
