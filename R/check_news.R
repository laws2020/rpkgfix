#' Verify NEWS.md Has an Entry for the Current Version
#'
#' @description
#' Checks that `NEWS.md` exists and contains a heading matching the current
#' `Version` in `DESCRIPTION` (e.g. `# rpkgfix 0.1.0`). Complements
#' `bump_version()`, which adds these entries.
#'
#' @param path Character. Package root. Defaults to `"."`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_news()
#' }
#' @export
check_news <- function(path = ".") {
  assert_package_root(path)

  desc    <- read_desc(file.path(path, "DESCRIPTION"))
  version <- trimws(desc[["Version"]])
  news_fp <- file.path(path, "NEWS.md")

  warnings <- character(0)
  notes    <- character(0)

  if (!file.exists(news_fp)) {
    return(rpf_report("check_news()",
                      notes = "No NEWS.md file - consider adding one to track changes."))
  }

  news <- paste(read_utf8(news_fp), collapse = "\n")
  # match the version anywhere in a heading line
  version_rx <- gsub("\\.", "\\\\.", version)
  if (!grepl(sprintf("(?m)^#+.*%s", version_rx), news, perl = TRUE)) {
    warnings <- c(warnings, sprintf(
      "NEWS.md has no heading for the current version (%s).", version))
  }

  rpf_report("check_news()", warnings = warnings, notes = notes)
}
