#' Detect Console Output in Package Code
#'
#' @description
#' Package code should emit diagnostics via `message()`/`warning()` (or a
#' messaging framework) so users can suppress them - not via `cat()` or
#' `print()`. This flags `cat()`/`print()` calls in `R/`. Comments and string
#' literals are stripped first, so the detection regex itself and docstrings
#' are not matched.
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_output()
#' }
#' @export
check_output <- function(dir = "R") {
  assert_package_root()

  warnings <- character(0)
  for (f in r_source_files(dir)) {
    code <- strip_code(read_utf8(f))
    for (i in seq_along(code)) {
      if (grepl("(?<![A-Za-z0-9._])(cat|print)\\s*\\(", code[[i]], perl = TRUE)) {
        warnings <- c(warnings, sprintf(
          "%s:%d uses cat()/print() - prefer message().", f, i))
      }
    }
  }

  rpf_report("check_output()", warnings = warnings)
}
