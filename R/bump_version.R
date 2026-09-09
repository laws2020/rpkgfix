#' Bump the Package Version and Add a NEWS Entry
#'
#' @description
#' Increments the `Version` field in `DESCRIPTION` (`patch`, `minor`, or
#' `major`) and prepends a matching heading to `NEWS.md`. Pure base R - no
#' dependency on `usethis`, so it works non-interactively (e.g. in CI).
#' Renamed from the old `bump()`.
#'
#' @param which Character. One of `"patch"`, `"minor"`, or `"major"`.
#'   Defaults to `"patch"`.
#' @param path Character. Package root. Defaults to `"."`.
#' @param update_news Logical. If `TRUE` (default), prepends a heading to
#'   `NEWS.md` (creating it if absent).
#' @param dry_run Logical. If `TRUE`, reports the new version without writing.
#'   Defaults to `FALSE`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, plus
#'   `old_version` and `new_version`.
#'
#' @examples
#' \dontrun{
#' bump_version()          # patch: 0.1.0 -> 0.1.1
#' bump_version("minor")   # 0.1.1 -> 0.2.0
#' bump_version("major")   # 0.2.0 -> 1.0.0
#' }
#' @export
bump_version <- function(which = c("patch", "minor", "major"),
                         path = ".",
                         update_news = TRUE,
                         dry_run = FALSE) {
  assert_package_root(path)
  which <- match.arg(which)

  desc_fp <- file.path(path, "DESCRIPTION")
  desc    <- read_desc(desc_fp)
  old_v   <- trimws(desc[["Version"]])

  parts <- as.integer(strsplit(old_v, "[.-]")[[1]])
  if (length(parts) < 3L || anyNA(parts[1:3])) {
    return(rpf_report("bump_version()",
                      errors = sprintf("Version '%s' is not in X.Y.Z form - cannot bump.", old_v)))
  }

  # Bump the requested component; reset lower components to 0
  if (which == "major") { parts[1] <- parts[1] + 1L; parts[2] <- 0L; parts[3] <- 0L }
  if (which == "minor") { parts[2] <- parts[2] + 1L; parts[3] <- 0L }
  if (which == "patch") { parts[3] <- parts[3] + 1L }
  new_v <- paste(parts[1:3], collapse = ".")

  notes <- sprintf("%s: %s -> %s", which, old_v, new_v)

  if (!dry_run) {
    # -- Rewrite the Version line in DESCRIPTION (preserve everything else) -----
    dcf_lines <- read_utf8(desc_fp)
    dcf_lines <- sub("^Version:.*$", paste0("Version: ", new_v), dcf_lines)
    write_utf8(dcf_lines, desc_fp)

    # -- Prepend a NEWS.md heading ----------------------------------------------
    if (update_news) {
      pkg     <- desc[["Package"]]
      heading <- sprintf("# %s %s", pkg, new_v)
      news_fp <- file.path(path, "NEWS.md")
      old_news <- if (file.exists(news_fp)) read_utf8(news_fp) else character(0)
      write_utf8(c(heading, "", "* ", "", old_news), news_fp)
      notes <- c(notes, sprintf("Prepended '%s' to NEWS.md.", heading))
    }
  } else {
    notes <- c(notes, "Dry run - no files were written.")
  }

  res <- rpf_report("bump_version()", notes = notes)
  res$old_version <- old_v
  res$new_version <- new_v
  invisible(res)
}
