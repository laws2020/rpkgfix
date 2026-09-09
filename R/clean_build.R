#' Remove Stale Build Artefacts from the Package Directory
#'
#' @description
#' Removes development debris that should never be committed or shipped:
#' `.RData`, `.Rhistory`, `*.tar.gz` bundles, `*.Rcheck` directories, and
#' orphaned `man/*.Rd` files (those with no matching function in `R/`).
#' Renamed from the old `clean_session()` (it cleans build artefacts, not the R
#' session).
#'
#' @param rdata Logical. Remove `.RData`. Default `TRUE`.
#' @param rhistory Logical. Remove `.Rhistory`. Default `TRUE`.
#' @param bundles Logical. Remove `*.tar.gz` and `*.Rcheck`. Default `TRUE`.
#' @param orphan_rd Logical. Remove orphaned `man/*.Rd`. Default `TRUE`.
#' @param dry_run Logical. If `TRUE`, lists what would be removed without
#'   deleting. Default `FALSE`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, plus a
#'   `deleted` element (character vector of paths).
#'
#' @examples
#' \dontrun{
#' clean_build(dry_run = TRUE)
#' clean_build()
#' }
#' @export
clean_build <- function(rdata     = TRUE,
                        rhistory  = TRUE,
                        bundles   = TRUE,
                        orphan_rd = TRUE,
                        dry_run   = FALSE) {
  assert_package_root()

  to_delete <- character(0)

  if (rdata    && file.exists(".RData"))    to_delete <- c(to_delete, ".RData")
  if (rhistory && file.exists(".Rhistory")) to_delete <- c(to_delete, ".Rhistory")

  if (bundles) {
    to_delete <- c(to_delete,
                   list.files(".", pattern = "\\.tar\\.gz$", full.names = TRUE),
                   list.dirs(".", recursive = FALSE, full.names = TRUE)[
                     grepl("\\.Rcheck$", list.dirs(".", recursive = FALSE, full.names = TRUE))])
  }

  # -- Orphaned man/*.Rd --------------------------------------------------------
  if (orphan_rd && dir.exists("man")) {
    rd_files <- list.files("man", pattern = "\\.Rd$", full.names = TRUE)
    records  <- parse_r_blocks(r_source_files("R"))
    fn_names <- vapply(records, function(r) r$name, character(1L))
    rd_bases <- tools::file_path_sans_ext(basename(rd_files))
    orphans  <- rd_files[!rd_bases %in% fn_names]
    # keep the package doc page
    orphans  <- orphans[!grepl("-package$", rd_bases)]
    to_delete <- c(to_delete, orphans)
  }

  to_delete <- unique(to_delete)

  if (!length(to_delete)) {
    return(rpf_report("clean_build()", notes = "Nothing to clean."))
  }

  notes <- character(0)
  verb  <- if (dry_run) "Would delete" else "Deleted"
  for (p in to_delete) {
    if (!dry_run) {
      ok <- tryCatch({ unlink(p, recursive = TRUE); TRUE },
                     error = function(e) FALSE)
      if (!ok) next
    }
    notes <- c(notes, sprintf("%s: %s", verb, p))
  }
  if (dry_run) notes <- c(notes, "Dry run - nothing was deleted.")

  res <- rpf_report("clean_build()", notes = notes)
  res$deleted <- to_delete
  invisible(res)
}
