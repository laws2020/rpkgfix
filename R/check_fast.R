#' Fast Namespace and Global Variable check_fast(
#'
#' @description
#' Runs a targeted `R CMD check` pass that focuses only on namespace problems
#' and undefined global variables - skipping examples, tests, vignettes, and
#' manual pages to give a quick feedback loop during development.
#'
#' @param pkg Character. Path to the package root. Defaults to `"."` (current
#'   directory).
#' @param quiet Logical. If `TRUE`, suppresses `devtools::check()` output and
#'   only prints the rpkgfix summary. Defaults to `TRUE`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, plus a
#'   `result` element holding the object returned by `devtools::check()`.
#'
#' @details
#' This function requires `devtools`, a `Suggests` dependency. It is
#' intentionally in `Suggests` rather than `Imports` because `devtools` is a
#' development tool and should not be a runtime dependency; the check is guarded
#' with `requireNamespace()`.
#'
#' The flags passed to `R CMD check` are:
#' - `--no-codoc`: skip code/documentation consistency
#' - `--no-examples`: skip example execution
#' - `--no-tests`: skip test suite
#' - `--no-manual`: skip PDF manual build
#' - `--no-vignettes`: skip vignette build
#'
#' @examples
#' \dontrun{
#' check_fast()
#' check_fast((quiet = FALSE)  # show full devtools output
#' }
#' @export
check_fast <- function(pkg = ".", quiet = TRUE) {
  assert_package_root(pkg)
  require_suggested("devtools")

  rpf_info("Running fast namespace check_fast (skipping examples, tests, vignettes)...")

  result <- devtools::check(
    pkg  = pkg,
    args = c(
      "--no-codoc",
      "--no-examples",
      "--no-tests",
      "--no-manual",
      "--no-vignettes"
    ),
    quiet = quiet
  )

  errors   <- as.character(result$errors)
  warnings <- as.character(result$warnings)
  notes    <- as.character(result$notes)

  res <- rpf_report("check_fast()", errors, warnings, notes)
  res$result <- result
  invisible(res)
}
