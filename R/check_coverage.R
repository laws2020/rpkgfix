#' Find Exported Functions With No Test Reference
#'
#' @description
#' Cross-references exported functions against `tests/testthat/` files. Any
#' exported function whose name never appears in a test file is flagged as
#' having no test coverage. This is a name-reference heuristic, not runtime
#' coverage (for that, use the `covr` package).
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#' @param test_dir Character. Test directory. Defaults to `"tests/testthat"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_coverage()
#' }
#' @export
check_coverage <- function(dir = "R", test_dir = "tests/testthat") {
  assert_package_root()

  records <- parse_r_blocks(r_source_files(dir))
  exported <- vapply(
    Filter(function(r) r$exported && !r$internal, records),
    function(r) r$name, character(1L))

  if (!dir.exists(test_dir)) {
    return(rpf_report("check_coverage()",
                      warnings = sprintf("No test directory '%s' - add tests/testthat/.", test_dir)))
  }

  test_files <- list.files(test_dir, pattern = "\\.[Rr]$", full.names = TRUE)
  test_text  <- paste(unlist(lapply(test_files, read_utf8)), collapse = "\n")

  untested <- exported[!vapply(exported, function(fn) {
    grepl(sprintf("\\b%s\\b", gsub("\\.", "\\\\.", fn)), test_text)
  }, logical(1L))]

  warnings <- if (length(untested))
    sprintf("No test reference for: %s", untested) else character(0)

  rpf_report("check_coverage()", warnings = warnings)
}
