#' Spell-Check DESCRIPTION and Rd Files
#'
#' @description
#' Runs an `aspell`-based spell check over `DESCRIPTION` and the `.Rd` files in
#' `man/`, mirroring what CRAN does. Uses `utils::aspell()`, which requires a
#' system spell checker (aspell/hunspell); if none is available, the check
#' degrades to a note rather than failing.
#'
#' @param path Character. Package root. Defaults to `"."`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`.
#'
#' @examples
#' \dontrun{
#' check_spelling()
#' }
#' @export
check_spelling <- function(path = ".") {
  assert_package_root(path)

  warnings <- character(0)
  notes    <- character(0)

  out <- tryCatch(
    utils::aspell_package_Rd_files(path),
    error = function(e) e
  )
  desc_out <- tryCatch(
    utils::aspell(file.path(path, "DESCRIPTION"), filter = "dcf"),
    error = function(e) e
  )

  if (inherits(out, "error") || inherits(desc_out, "error")) {
    notes <- c(notes,
               "No system spell checker (aspell/hunspell) available - skipped.")
  } else {
    words <- unique(c(
      if (nrow(out))      out$Original      else character(0),
      if (nrow(desc_out)) desc_out$Original else character(0)
    ))
    if (length(words)) {
      warnings <- sprintf("Possible misspelling: %s", words)
    }
  }

  rpf_report("check_spelling()", warnings = warnings, notes = notes)
}
