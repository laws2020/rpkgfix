#' Detect Common Style Anti-Patterns
#'
#' @description
#' Scans `R/` source for anti-patterns CRAN reviewers commonly flag: `T`/`F`
#' instead of `TRUE`/`FALSE`, `sapply()` (type-unstable), and `1:length(x)` /
#' `1:nrow(x)` / `1:ncol(x)` (unsafe when the length is zero). Comments and
#' string literals are stripped before scanning so pattern definitions and
#' documentation do not trigger false positives.
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_style()
#' }
#' @export
check_style <- function(dir = "R") {
  assert_package_root()

  patterns <- list(
    "Use TRUE/FALSE, not T/F"                    = "(?<![A-Za-z0-9._])[TF](?![A-Za-z0-9._])",
    "Prefer vapply()/lapply() over sapply()"     = "\\bsapply\\(",
    "Use seq_len()/seq_along() not 1:length(x)"  = "1:(length|nrow|ncol)\\("
  )

  warnings <- character(0)
  for (f in r_source_files(dir)) {
    code <- strip_code(read_utf8(f))
    for (i in seq_along(code)) {
      for (label in names(patterns)) {
        if (grepl(patterns[[label]], code[[i]], perl = TRUE)) {
          warnings <- c(warnings, sprintf("%s:%d - %s", f, i, label))
        }
      }
    }
  }

  rpf_report("check_style()", warnings = warnings)
}
