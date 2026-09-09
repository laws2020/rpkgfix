#' Detect NAMESPACE vs @export Drift
#'
#' @description
#' Compares `export()` entries in `NAMESPACE` against `@export`-tagged functions
#' in `R/`. Any mismatch means you need to re-run `roxygen2::roxygenise()` /
#' `devtools::document()`.
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#' @param namespace Character. Path to NAMESPACE. Defaults to `"NAMESPACE"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_namespace()
#' }
#' @export
check_namespace <- function(dir = "R", namespace = "NAMESPACE") {
  assert_package_root()

  errors <- character(0)
  notes  <- character(0)

  if (!file.exists(namespace)) {
    return(rpf_report("check_namespace()",
                      errors = "No NAMESPACE file - run roxygen2::roxygenise() to generate it."))
  }

  ns_lines <- read_utf8(namespace)
  exported_ns <- unlist(regmatches(
    ns_lines, regexpr("(?<=^export\\().*(?=\\))", ns_lines, perl = TRUE)))
  exported_ns <- trimws(gsub("[\"']", "", exported_ns))

  records <- parse_r_blocks(r_source_files(dir))
  exported_src <- vapply(
    Filter(function(r) r$exported && !r$internal, records),
    function(r) r$name, character(1L))

  missing_from_ns  <- setdiff(exported_src, exported_ns)  # tagged but not documented
  stale_in_ns      <- setdiff(exported_ns, exported_src)  # exported but no @export tag

  if (length(missing_from_ns)) {
    errors <- c(errors, sprintf(
      "@export in source but not in NAMESPACE (re-document): %s",
      paste(missing_from_ns, collapse = ", ")))
  }
  if (length(stale_in_ns)) {
    errors <- c(errors, sprintf(
      "In NAMESPACE but no matching @export in source (stale): %s",
      paste(stale_in_ns, collapse = ", ")))
  }

  if (any(grepl("^exportPattern", ns_lines))) {
    notes <- c(notes, "NAMESPACE uses exportPattern() - per-function comparison is approximate.")
  }

  rpf_report("check_namespace()", errors, notes = notes)
}
