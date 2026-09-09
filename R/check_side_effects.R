#' Detect Anti-Pattern Side-Effect Calls in Package Code
#'
#' @description
#' Package code should never call `library()`, `require()`, or
#' `installed.packages()`. Dependencies belong in `DESCRIPTION` and are used
#' via `::` or `@importFrom`. This flags any such call in `R/`. Comments and
#' string literals are stripped first so the detection regex and docstrings do
#' not match.
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_side_effects()
#' }
#' @export
check_side_effects <- function(dir = "R") {
  assert_package_root()

  banned <- "(?<![A-Za-z0-9._])(library|require|installed\\.packages)\\s*\\("

  warnings <- character(0)
  for (f in r_source_files(dir)) {
    code <- strip_code(read_utf8(f))
    for (i in seq_along(code)) {
      if (grepl(banned, code[[i]], perl = TRUE)) {
        warnings <- c(warnings, sprintf(
          "%s:%d calls library()/require()/installed.packages().", f, i))
      }
    }
  }

  rpf_report("check_side_effects()", warnings = warnings)
}
