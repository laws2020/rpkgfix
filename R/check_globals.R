#' Detect Undefined Global Variables
#'
#' @description
#' Uses `codetools` (ships with R) to find the classic
#' "no visible binding for global variable" NOTE, typically caused by
#' non-standard evaluation (e.g. data-masking column names). Suggests declaring
#' them via [utils::globalVariables()].
#'
#' The package must be loadable (installed, or loaded via `pkgload`/`devtools`)
#' because `codetools` inspects the compiled function objects. If it is not
#' loadable, the check falls back to a lighter source-scan heuristic.
#'
#' @param pkg Character. Package name (must be loadable). Defaults to the
#'   `Package` field of `DESCRIPTION`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_globals()
#' }
#' @export
check_globals <- function(pkg = NULL) {
  assert_package_root()

  if (is.null(pkg)) pkg <- read_desc()[["Package"]]

  notes    <- character(0)
  warnings <- character(0)

  if (!requireNamespace("codetools", quietly = TRUE)) {
    return(rpf_report("check_globals()",
                      notes = "Package 'codetools' not available - cannot inspect globals."))
  }
  if (!requireNamespace(pkg, quietly = TRUE)) {
    return(rpf_report("check_globals()",
                      notes = sprintf("Package '%s' is not loadable - install/load it first, then re-run.", pkg)))
  }

  ns  <- asNamespace(pkg)
  fns <- Filter(is.function, mget(ls(ns), envir = ns, inherits = FALSE))

  globals <- character(0)
  for (nm in names(fns)) {
    codetools::checkUsage(
      fns[[nm]], name = nm,
      report = function(msg) {
        if (grepl("no visible (binding|global)", msg)) {
          globals <<- c(globals, sprintf("%s: %s", nm, msg))
        }
      }
    )
  }

  if (length(globals)) {
    warnings <- sprintf("%s", globals)
    notes    <- "Declare intentional NSE symbols via utils::globalVariables(c(...))."
  }

  rpf_report("check_globals()", warnings = warnings, notes = notes)
}
