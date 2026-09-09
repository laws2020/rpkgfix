#' Populate .Rbuildignore With Non-Standard Files and Folders
#'
#' @description
#' Scans the package root for non-standard folders *and* common stray files
#' (e.g. `cran-comments.md`, `*.Rproj`, `.github`) and adds correctly anchored
#' regex patterns to `.Rbuildignore`. Safe to run repeatedly - existing
#' patterns are not duplicated. Renamed from the old `ignore()`.
#'
#' @param extra Character vector of additional patterns to always add.
#'   Defaults to `character(0)`.
#' @param standard_folders Character vector of folders that are part of the
#'   standard package structure and should not be ignored.
#' @param dry_run Logical. If `TRUE`, reports what would be added without
#'   writing. Defaults to `FALSE`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, plus an
#'   `added` element (character vector of patterns written).
#'
#' @examples
#' \dontrun{
#' fix_buildignore()
#' fix_buildignore(dry_run = TRUE)
#' }
#' @export
fix_buildignore <- function(
    extra = character(0),
    standard_folders = c(
      "R", "man", "data", "data-raw", "inst", "tests",
      "vignettes", "src", "po", "exec", "tools", "demo"
    ),
    dry_run = FALSE) {
  assert_package_root()

  # -- Non-standard folders (skip hidden and underscore-prefixed) --------------
  all_dirs  <- list.dirs(".", recursive = FALSE, full.names = FALSE)
  all_dirs  <- all_dirs[nchar(all_dirs) > 0]
  all_dirs  <- all_dirs[!startsWith(all_dirs, ".")]
  all_dirs  <- all_dirs[!startsWith(all_dirs, "_")]
  ns_folders <- setdiff(all_dirs, standard_folders)
  folder_patterns <- if (length(ns_folders)) paste0("^", ns_folders, "$") else character(0)

  # -- Common stray files that should never ship in the tarball ----------------
  known_file_patterns <- c(
    "^cran-comments\\.md$",
    "^.*\\.Rproj$",
    "^\\.Rproj\\.user$",
    "^\\.github$",
    "^README\\.Rmd$",
    "^doc$",
    "^Meta$"
  )
  present_files <- known_file_patterns[vapply(
    c("cran-comments.md", list.files(".", pattern = "\\.Rproj$"),
      ".Rproj.user", ".github", "README.Rmd", "doc", "Meta"),
    function(x) file.exists(x) || dir.exists(x),
    logical(1L)
  )]

  wanted <- unique(c(folder_patterns, present_files, extra))
  if (!length(wanted)) {
    return(rpf_report("fix_buildignore()",
                      notes = "Nothing to add to .Rbuildignore."))
  }

  existing <- if (file.exists(".Rbuildignore")) read_utf8(".Rbuildignore") else character(0)
  to_add   <- setdiff(wanted, trimws(existing))

  if (!length(to_add)) {
    return(rpf_report("fix_buildignore()",
                      notes = ".Rbuildignore already covers everything."))
  }

  if (!dry_run) {
    write_utf8(c(existing, to_add), ".Rbuildignore")
  }

  verb  <- if (dry_run) "Would add" else "Added"
  notes <- sprintf("%s to .Rbuildignore: %s", verb, to_add)
  if (dry_run) notes <- c(notes, "Dry run - .Rbuildignore not modified.")

  res <- rpf_report("fix_buildignore()", notes = notes)
  res$added <- to_add
  invisible(res)
}
