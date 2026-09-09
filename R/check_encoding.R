#' Detect Non-ASCII Characters in Source and DESCRIPTION
#'
#' @description
#' Flags non-ASCII bytes in `R/` source files and in `DESCRIPTION`, a frequent
#' cause of CRAN rejection. Reports the file and line of each offending
#' character.
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_encoding()
#' }
#' @export
check_encoding <- function(dir = "R") {
  assert_package_root()

  warnings <- character(0)
  files    <- c(r_source_files(dir), "DESCRIPTION")

  for (f in files) {
    if (!file.exists(f)) next
    lines <- read_utf8(f)
    for (i in seq_along(lines)) {
      # non-ASCII == any byte above 0x7F
      if (grepl("[^\x01-\x7F]", lines[[i]], perl = TRUE)) {
        warnings <- c(warnings, sprintf("%s:%d has non-ASCII characters.", f, i))
      }
    }
  }

  rpf_report("check_encoding()", warnings = warnings)
}
