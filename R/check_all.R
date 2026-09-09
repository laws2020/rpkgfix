#' Run the Full rpkgfix Diagnostic Suite
#'
#' @description
#' Runs every read-only `check_*()` diagnostic in one pass and prints a
#' consolidated summary of total errors, warnings, and notes. Ideal as a
#' pre-commit / pre-push step or a first look before `devtools::check()`.
#'
#' @param dir Character. Directory containing `.R` source files. Defaults to
#'   `"R"`.
#' @param path Character. Package root. Defaults to `"."`.
#' @param checks Character vector. Which diagnostics to run. Defaults to all
#'   fifteen `check_*` functions. Pass a subset to run only those.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, plus a
#'   named `results` element holding each individual check's return value.
#'
#' @details
#' Each diagnostic returns `list(ok, errors, warnings, notes)`; `check_all()`
#' concatenates those vectors across all checks so the top-level `ok` is `TRUE`
#' only when no check reported an error. `check_deps()` and `check_globals()`
#' are excluded from the default set because they need a package *name* /
#' loadable package rather than a source directory - run them directly.
#'
#' @examples
#' \dontrun{
#' check_all()
#' res <- check_all()
#' res$results$check_description$errors
#' }
#' @export
check_all <- function(dir = "R",
                     path = ".",
                     checks = c(
                       "check_description",
                       "check_license",
                       "check_imports",
                       "check_docs",
                       "check_namespace",
                       "check_encoding",
                       "check_style",
                       "check_examples",
                       "check_coverage",
                       "check_spelling",
                       "check_output",
                       "check_side_effects",
                       "check_news"
                     )) {
  assert_package_root(path)

  version <- tryCatch(read_desc(file.path(path, "DESCRIPTION"))[["Version"]],
                      error = function(e) "")
  rpf_rule(left = "rpkgfix::check_all()", right = version)

  # Map each check name to how it is called (dir- vs path-based).
  dir_based  <- c("check_imports", "check_docs", "check_namespace",
                  "check_encoding", "check_style", "check_examples",
                  "check_coverage", "check_output", "check_side_effects")
  path_based <- c("check_license", "check_spelling", "check_news")

  results  <- list()
  errors   <- character(0)
  warnings <- character(0)
  notes    <- character(0)

  for (nm in checks) {
    fn <- get(nm, mode = "function")

    res <- if (nm == "check_description") {
      fn(file.path(path, "DESCRIPTION"))
    } else if (nm %in% dir_based) {
      fn(dir)
    } else if (nm %in% path_based) {
      fn(path)
    } else {
      fn()
    }

    results[[nm]] <- res
    errors   <- c(errors,   res$errors)
    warnings <- c(warnings, res$warnings)
    notes    <- c(notes,    res$notes)
  }

  # -- Consolidated banner -----------------------------------------------------
  rpf_rule(left = "Summary")

  if (length(errors)) {
    rpf_danger(sprintf("%d blocking error%s - fix before devtools::check().",
                       length(errors), plural(errors)))
  } else if (length(warnings)) {
    rpf_warn(sprintf("%d warning%s - review before CRAN submission.",
                     length(warnings), plural(warnings)))
  } else {
    rpf_success("All checks passed. Package looks healthy.")
  }
  if (length(notes)) {
    rpf_info(sprintf("%d note%s.", length(notes), plural(notes)))
  }

  invisible(list(
    ok       = length(errors) == 0L,
    errors   = errors,
    warnings = warnings,
    notes    = notes,
    results  = results
  ))
}
