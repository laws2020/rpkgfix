#' Report the Recursive Dependency Weight of a Package
#'
#' @description
#' Reports how many recursive dependencies a package pulls in before you add it
#' to `DESCRIPTION`, helping you avoid dependency bloat. Renamed from the old
#' `is_heavy()` because it returns a count, not a logical.
#'
#' @param pkg Character. Name of the package to check.
#' @param threshold Integer. Count above which the package is flagged as
#'   "heavy". Defaults to `50`.
#' @param which Character vector passed to [tools::package_dependencies()].
#'   Defaults to `c("Imports", "Depends", "LinkingTo")`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, plus a
#'   `count` element (named integer).
#'
#' @examples
#' \dontrun{
#' check_deps("ggplot2")
#' }
#' @export
check_deps <- function(pkg,
                       threshold = 50L,
                       which = c("Imports", "Depends", "LinkingTo")) {
  if (!is.character(pkg) || length(pkg) != 1L) {
    stop("`pkg` must be a single package name string.", call. = FALSE)
  }

  deps_list <- tools::package_dependencies(pkg, which = which, recursive = TRUE)

  if (is.null(deps_list) || is.null(deps_list[[pkg]])) {
    stop(sprintf("Package '%s' was not found in the available repositories.", pkg),
         call. = FALSE)
  }

  deps  <- deps_list[[pkg]]
  count <- length(deps)

  warnings <- character(0)
  notes    <- character(0)
  rpf_info(sprintf("%s brings in %d recursive dependenc%s.",
                   pkg, count, if (count == 1L) "y" else "ies"))

  if (count > threshold) {
    warnings <- sprintf("Heavy dependency: exceeds threshold of %d.", threshold)
  } else {
    notes <- sprintf("Within threshold of %d.", threshold)
  }

  res <- rpf_report("check_deps()", warnings = warnings, notes = notes)
  res$count <- stats::setNames(count, pkg)
  invisible(res)
}
