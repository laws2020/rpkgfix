#' Prefix Bare Function Calls with Package Namespaces
#'
#' @description
#' Adds `pkg::` prefixes to bare function calls across all `.R` files in a
#' directory, using a lookup table (see [default_mapping()]). Safe to run
#' repeatedly - it will not double-prefix calls that already carry a namespace.
#' Renamed from the old `prefix_all()`.
#'
#' @param dir Character. Directory containing `.R` files. Defaults to `"R"`.
#' @param mapping Named list mapping package names to character vectors of
#'   function names. Defaults to [default_mapping()].
#' @param dry_run Logical. If `TRUE`, reports what would change without writing
#'   any files. Defaults to `FALSE`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, plus a
#'   `changes` element: a named list of the substitutions made per file.
#'
#' @details
#' The substitution uses a Perl lookbehind so a call is only prefixed when it is
#' *not* already namespaced (`(?<![A-Za-z0-9_]::)`) and *not* part of a dotted
#' name (`(?<!\.)`). Files are read and written as UTF-8.
#'
#' @examples
#' \dontrun{
#' add_namespaces()
#' add_namespaces(dry_run = TRUE)
#' }
#' @export
add_namespaces <- function(dir = "R",
                           mapping = default_mapping(),
                           dry_run = FALSE) {
  assert_package_root()
  if (!dir.exists(dir)) {
    stop(sprintf("Directory '%s' does not exist.", dir), call. = FALSE)
  }

  files <- r_source_files(dir)
  if (!length(files)) {
    return(rpf_report("add_namespaces()",
                      notes = sprintf("No .R files found in '%s'.", dir)))
  }

  changes_by_file <- list()
  notes <- character(0)

  for (f in files) {
    content  <- read_utf8(f)
    original <- content
    changes  <- character(0)

    for (pkg in names(mapping)) {
      for (func in mapping[[pkg]]) {
        func_rx     <- gsub("\\.", "\\\\.", func)  # escape dots in the name
        pattern     <- paste0("(?<![A-Za-z0-9_]::)(?<!\\.)\\b", func_rx, "\\(")
        replacement <- paste0(pkg, "::", func, "(")
        new_content <- gsub(pattern, replacement, content, perl = TRUE)

        if (!identical(new_content, content)) {
          changes <- c(changes, sprintf("%s() -> %s::%s()", func, pkg, func))
          content <- new_content
        }
      }
    }

    changes_by_file[[f]] <- changes

    if (!dry_run && !identical(content, original)) {
      write_utf8(content, f)
    }

    if (length(changes)) {
      verb <- if (dry_run) "Would change" else "Changed"
      notes <- c(notes,
                 sprintf("%s %d call(s) in %s: %s",
                         verb, length(changes), f, paste(changes, collapse = "; ")))
    }
  }

  if (!length(notes)) {
    notes <- "No bare calls needed prefixing."
  } else if (dry_run) {
    notes <- c(notes, "Dry run - no files were written.")
  }

  res <- rpf_report("add_namespaces()", notes = notes)
  res$changes <- changes_by_file
  invisible(res)
}
