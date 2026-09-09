#' Verify LICENSE File Consistency with DESCRIPTION
#'
#' @param path Character. Path to the package root. Defaults to `"."`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, and `notes`.
#'
#' @examples
#' \dontrun{
#' check_license()
#' }
#' @export
check_license <- function(path = ".") {
  assert_package_root(path)

  desc     <- read_desc(file.path(path, "DESCRIPTION"))
  license  <- trimws(desc[["License"]])
  errors   <- character(0)
  warnings <- character(0)
  notes    <- character(0)

  standard_no_file <- c(
    "MIT", "GPL-2", "GPL-3", "LGPL-2.1", "LGPL-3", "AGPL-3",
    "Apache License 2.0", "CC BY 4.0", "CC0", "BSD_2_clause", "BSD_3_clause"
  )

  needs_file  <- grepl("file LICENSE", license, ignore.case = TRUE)
  license_fp  <- file.path(path, "LICENSE")
  has_file    <- file.exists(license_fp)
  is_standard <- any(vapply(standard_no_file, grepl, logical(1L),
                            x = license, fixed = TRUE))

  if (needs_file && !has_file) {
    errors <- c(errors, sprintf(
      "DESCRIPTION declares '%s' but no LICENSE file found.", license))
  }
  if (!needs_file && has_file && !is_standard) {
    warnings <- c(warnings,
                  "A LICENSE file exists but DESCRIPTION does not reference it with '+ file LICENSE'.")
  }
  if (!is_standard && !needs_file) {
    warnings <- c(warnings, sprintf(
      "License '%s' is not a recognised CRAN standard.", license))
  }

  if (has_file) {
    content <- read_utf8(license_fp)
    if (length(content) == 0L || all(nchar(trimws(content)) == 0L)) {
      errors <- c(errors, "LICENSE file exists but is empty.")
    }
    if (grepl("MIT", license, fixed = TRUE) &&
        grepl("YEAR|COPYRIGHT HOLDER", paste(content, collapse = "\n"))) {
      warnings <- c(warnings,
                    "LICENSE still contains YEAR or COPYRIGHT HOLDER placeholders.")
    }
  }

  rpf_info(sprintf("Declared license: %s", license))
  rpf_report("check_license()", errors, warnings, notes)
}
