#' Flag Exported Functions Whose Examples Are Non-Runnable
#'
#' @description
#' Exported functions should have at least one runnable example. This flags
#' functions whose `@examples` block exists but is entirely wrapped in
#' `\dontrun{}` (or `\donttest{}`), and those with no `@examples` at all.
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_examples()
#' }
#' @export
check_examples <- function(dir = "R") {
  assert_package_root()

  records  <- parse_r_blocks(r_source_files(dir))
  warnings <- character(0)
  notes    <- character(0)

  for (r in records) {
    if (!r$exported || r$internal) next

    roxy <- paste(r$roxygen, collapse = "\n")
    has_examples <- grepl("@examples", roxy)

    if (!has_examples) {
      notes <- c(notes, sprintf("%s() has no @examples.", r$name))
      next
    }

    ex <- sub(".*@examples", "", roxy)
    # Strip whitespace/roxygen markers to see if anything runs unwrapped
    stripped <- gsub("#'|\\s", "", ex)
    only_dontrun <- grepl("^(\\\\dontrun|\\\\donttest)\\{", stripped) &&
      !grepl("\\}[^}]*[A-Za-z0-9]", stripped)

    if (only_dontrun) {
      warnings <- c(warnings, sprintf(
        "%s() examples are entirely wrapped in \\dontrun/\\donttest.", r$name))
    }
  }

  rpf_report("check_examples()", warnings = warnings, notes = notes)
}
