#' Auto-Fix an R Script via Iterative LLM Debugging
#'
#' Executes an R script in an isolated sandbox. If execution fails, the error
#' is passed to an LLM (currently only Google Gemini) which attempts to fix the
#' script. This loop repeats up to \code{max_runs} times.
#'
#' @param file Path to the R script to run and debug.
#' @param data Optional path to a CSV data file to make available inside
#'   the sandbox at \code{data/<basename>}.
#' @param max_runs Maximum number of LLM fix attempts. Default is \code{5}.
#' @param model Gemini model string. Default is \code{"gemini-2.5-pro"}.
#' @param verbose If \code{TRUE}, saves a copy of the script at each iteration.
#' @param as_job If \code{TRUE}, runs the process as a background job. If
#'   \code{FALSE} (default), runs in the current R session. Only used when \code{engine = "callr"}.
#' @param engine One of \code{"callr"} (default) or \code{"docker"}. Controls
#'   the execution to be with \code{callr} in a temp directory sandbox (in session or as a background job),
#'   or within a Docker container. 
#' @param scan_code If \code{TRUE} (default), scans the script for potentially
#'   dangerous file system commands before execution.
#'
#' @return Invisibly returns a list with:
#'   \describe{
#'     \item{success}{Logical. Whether the script ran without error.}
#'     \item{file}{Path to the (possibly fixed) script.}
#'     \item{chat_history}{The \code{ellmer} chat object with full history.}
#'   }
#' @export
#' @examples
#' \dontrun{
#' validate_script(
#'   file = here::here("test/dplyr-filter-equal.R"),
#'   data = here::here("data/dplyr-filter-equal.csv")
#' )
#' }
#'
validate_script <- function(file, data = NULL, max_runs = 5,
                            model = "gemini-2.5-pro", verbose = TRUE,
                            as_job = FALSE, engine = c("callr", "docker"),
                            scan_code = TRUE) {
  engine <- match.arg(engine)

  attempt <- 1
  success <- FALSE
  extracted_data <- NULL

  while (attempt <= max_runs && !success) {
    cli::cli_inform(c(
      "i" = "[Attempt {attempt} of {max_runs}] Running script in sandbox..."
    ))

    if (verbose) save_verbose_iteration(sandbox$script, file, attempt)

    # run the script either in a docker or with callr (either in the console or as a background job - not implemented yet)
    if (engine == "docker") {
      # TODO: not tested
      res <- execute_in_docker(sandbox$script, sandbox$dir)
    } else {
      
      # setup a temp directory sandbox for running with callr
      sandbox <- setup_sandbox(file, data)
      on.exit({
        unlink(sandbox$dir, recursive = TRUE)
        cli::cli_inform("Sandbox destroyed.")
      },
        add = TRUE
      )

      if (scan_code) scan_file_system_commands(sandbox$script)
      res <- execute_in_callr(sandbox$script, sandbox$dir, as_job = as_job)
    }

    # check result and ask LLM to fix
    if (res$ok) {
      cli::cli_inform(c("v" = "Success! Script ran perfectly."))
      success <- TRUE
      extracted_data <- res$data
      file.copy(sandbox$script, file, overwrite = TRUE)
    } else {
      cli::cli_inform(c("x" = "Execution Failed: {res$err_msg}"))
      if (attempt < max_runs) {
        # as LLM to fix
        cli::cli_inform(c("i" = "Asking LLM to fix it..."))
        sys_prompt <- build_sys_prompt(data)
        chat <- ellmer::chat_google_gemini(model = model)
        ask_llm_for_fix(chat, sys_prompt, sandbox$script, res)
      }
    }
    attempt <- attempt + 1
  }

  invisible(list(success = success, file = file, chat_history = chat))
}

build_sys_prompt <- function(data) {
  data_context <- ""
  if (!is.null(data)) {
    data_context <- sprintf(
      "The user has provided a data file located at the relative path: `data/%s'. ",
      basename(data)
    )
  }

  paste0(
    "You are an expert R developer and automated debugging agent. ",
    data_context,
    "Your purpose is to receive broken R scripts, diagnose the execution error,
    and return the corrected script.

    CRITICAL INSTRUCTIONS:
    1. Fix the bug while preserving the original intent and logic of the script.
    2. If the error is a missing package, add the necessary `library()` call at the top.
    3. If the error is a missing variable, ensure it is properly initialized before use.
    4. Do NOT hallucinate new data files or external dependencies unless explicitly provided in the context.

    STRICT OUTPUT CONSTRAINTS:
    - You must output ONLY valid, fully executable R code.
    - Absolutely NO markdown formatting. Do NOT wrap your response in ```R or ```.
    - Absolutely NO conversational filler, greetings, explanations, or comments about what you fixed.
    - The first character of your response must be R code, and the last character must be R code."
  )
}

setup_sandbox <- function(file_path, data) {
  sandbox_dir <- tempfile("llm_sandbox_")
  dir.create(sandbox_dir)
  file.create(file.path(sandbox_dir, ".here"))

  if (!is.null(data)) {
    if (file.exists(data)) {
      dir.create(file.path(sandbox_dir, "data"), recursive = TRUE, showWarnings = FALSE)
      file.copy(
        from = data,
        to = file.path(sandbox_dir, "data", basename(data)),
        overwrite = TRUE
      )
      cli::cli_inform("Transferred file {.file {data}} into the sandbox.")
    } else {
      cli::cli_warn("Data file {.file {data}} not found. Running without it.")
    }
  }

  sandbox_script <- file.path(sandbox_dir, basename(file_path))
  file.copy(file_path, sandbox_script, overwrite = TRUE)

  list(dir = sandbox_dir, script = sandbox_script)
}

execute_in_callr <- function(sandbox_script, sandbox_dir, as_job) {
  tryCatch(
    {
      callr::r(
        function(f) {
          temp_env <- new.env()

          exprs <- tryCatch(
            parse(f),
            error = function(e) {
              list(
                ok = FALSE,
                data = NULL,
                err_msg = e$message,
                bad_line = "Syntax Error (Code could not be parsed)"
              )
            }
          )

          if (is.list(exprs) && identical(exprs$ok, FALSE)) {
            return(exprs)
          }

          for (i in seq_along(exprs)) {
            step_result <- tryCatch(
              {
                eval(exprs[[i]], envir = temp_env)
                NULL
              },
              error = function(e) {
                list(
                  ok = FALSE,
                  data = NULL,
                  err_msg = e$message,
                  bad_line = paste(deparse(exprs[[i]]), collapse = "\n")
                )
              }
            )
            if (!is.null(step_result)) return(step_result)
          }

          list(ok = TRUE, data = as.list(temp_env), err_msg = NA, bad_line = NA)
        },
        args = list(f = sandbox_script),
        wd = sandbox_dir,
        show = FALSE
      )
    },
    error = function(e) {
      list(
        ok = FALSE,
        data = NULL,
        err_msg = paste("Sandbox Crash:", e$message),
        bad_line = "System Level Crash"
      )
    }
  )
}

execute_in_docker <- function(sandbox_script, sandbox_dir) {
  args <- c(
    "run",
    "--rm",
    "-v",
    paste0(sandbox_dir, ":/workspace"),
    "-w",
    "/workspace",
    "rocker/r-base",
    "Rscript",
    basename(sandbox_script)
  )

  res <- processx::run("docker", args, error_on_status = FALSE)

  if (res$status == 0) {
    list(ok = TRUE, data = NULL, err_msg = NA, bad_line = NA)
  } else {
    list(
      ok = FALSE,
      data = NULL,
      err_msg = res$stderr,
      bad_line = "Failed in Docker Container"
    )
  }
}

ask_llm_for_fix <- function(
  chat,
  sys_prompt,
  sandbox_script,
  execution_result
) {
  current_code <- paste(
    readLines(sandbox_script, warn = FALSE),
    collapse = "\n"
  )

  prompt <- sprintf(
    "%s\n\n--- BROKEN SCRIPT ---\n\n%s\n\n--- EXECUTION ERROR ---\nFailing Expression:\n\n%s\n\nError Message:\n\n%s\n\nReturn the completely fixed script now, adhering strictly to the output constraints.",
    sys_prompt,
    current_code,
    execution_result$bad_line,
    execution_result$err_msg
  )

  new_code <- chat$chat(prompt, echo = FALSE)
  new_code <- gsub("^```[rR]?\n", "", new_code)
  new_code <- gsub("\n```$", "", new_code)
  new_code <- trimws(new_code)

  writeLines(new_code, sandbox_script)
}

scan_file_system_commands <- function(script_path) {
  code <- readLines(script_path, warn = FALSE)
  threats <- c("file.remove", "unlink", "system\\(", "system2\\(", "file.create")

  for (line in code) {
    for (threat in threats) {
      if (grepl(threat, line)) {
        cli::cli_abort(
          "SECURITY ALERT: Malicious keyword {.code {threat}} detected. Execution aborted."
        )
      }
    }
  }
}

save_verbose_iteration <- function(sandbox_script, original, attempt) {
  dir_name <- dirname(original)
  base_name <- tools::file_path_sans_ext(basename(original))
  ext <- tools::file_ext(original)
  if (ext == "") {ext <- "R"}

  iter_file <- file.path(dir_name, sprintf("%s_iter%d.%s", base_name, attempt, ext))
  file.copy(sandbox_script, iter_file, overwrite = TRUE)
}
