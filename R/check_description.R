#' Diagnose Common DESCRIPTION Field Problems
#'
#' @description
#' Reads `DESCRIPTION` and checks for the most common problems that cause
#' `R CMD check` warnings or CRAN rejections: missing fields, placeholder text,
#' malformed `Authors@R`, missing `URL`/`BugReports`, and packages listed in
#' both `Imports` and `Suggests`.
#'
#' @param path Character. Path to the `DESCRIPTION` file. Defaults to
#'   `"DESCRIPTION"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, and `notes`.
#'
#' @examples
#' \dontrun{
#' check_description()
#' }
#' @export
check_description <- function(path = "DESCRIPTION") {
  if (!file.exists(path)) {
    stop(sprintf("No DESCRIPTION file found at '%s'.", path), call. = FALSE)
  }

  desc     <- read_desc(path)
  errors   <- character(0)
  warnings <- character(0)
  notes    <- character(0)

  # Required fields
  for (field in c("Package", "Title", "Version", "Description", "License")) {
    if (is.null(desc[[field]]) || nchar(trimws(desc[[field]])) == 0L) {
      errors <- c(errors, sprintf("Missing required field: %s", field))
    }
  }

  has_authors_r   <- !is.null(desc[["Authors@R"]])
  has_legacy_auth <- !is.null(desc[["Author"]]) && !is.null(desc[["Maintainer"]])
  if (!has_authors_r && !has_legacy_auth) {
    errors <- c(errors,
                "No authorship field. Add `Authors@R` (preferred) or `Author`+`Maintainer`.")
  }

  # Title
  title <- desc[["Title"]]
  if (!is.null(title)) {
    if (grepl("\\.$", trimws(title))) {
      warnings <- c(warnings, "Title ends with a full stop - CRAN forbids a terminal period.")
    }
    if (grepl("^(this package|an r package)", tolower(trimws(title)))) {
      warnings <- c(warnings, "Title starts with 'This package'/'An R package' - avoid redundancy.")
    }
  }

  # Description
  dtxt <- desc[["Description"]]
  if (!is.null(dtxt) && grepl("^this package", tolower(trimws(dtxt)))) {
    warnings <- c(warnings, "Description starts with 'This package' - CRAN discourages this.")
  }

  # Version format
  version <- desc[["Version"]]
  if (!is.null(version) &&
      !grepl("^[0-9]+\\.[0-9]+(\\.[0-9]+(\\.[0-9]+)?)?$", trimws(version))) {
    warnings <- c(warnings,
                  sprintf("Version '%s' does not follow X.Y.Z or X.Y.Z.9000.", version))
  }

  # Authors@R has a 'cre'
  if (has_authors_r && !grepl("cre", desc[["Authors@R"]])) {
    errors <- c(errors, "Authors@R has no 'cre' (maintainer) role - CRAN requires exactly one.")
  }

  # URL / BugReports / Encoding
  if (is.null(desc[["URL"]]))        notes <- c(notes, "No URL field.")
  if (is.null(desc[["BugReports"]])) notes <- c(notes, "No BugReports field.")
  if (is.null(desc[["Encoding"]]))   notes <- c(notes, "No Encoding field - set `Encoding: UTF-8`.")

  # Imports vs Suggests overlap
  overlap <- intersect(parse_pkgs(desc, "Imports"), parse_pkgs(desc, "Suggests"))
  if (length(overlap)) {
    errors <- c(errors,
                sprintf("Package(s) in both Imports and Suggests: %s",
                        paste(overlap, collapse = ", ")))
  }

  rpf_report("check_description()", errors, warnings, notes)
}
