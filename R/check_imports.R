#' Check That Declared Imports Match Actual Usage
#'
#' @description
#' Compares the packages declared in the `Imports` field of `DESCRIPTION`
#' against the packages actually referenced via `pkg::` in `R/`. Reports
#' declared-but-unused imports and used-but-undeclared packages. Comments and
#' string literals are stripped before scanning so mentions of `pkg::` inside
#' docstrings or format strings are not counted.
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, plus
#'   `unused` and `undeclared` package-name vectors.
#'
#' @examples
#' \dontrun{
#' check_imports()
#' }
#' @export
check_imports <- function(dir = "R") {
  assert_package_root()

  desc     <- read_desc()
  declared <- parse_pkgs(desc, "Imports")

  base_pkgs <- c("base", "methods", "utils", "stats", "graphics",
                 "grDevices", "datasets", "tools", "compiler", "parallel",
                 "splines", "grid")

  used <- character(0)
  for (f in r_source_files(dir)) {
    code <- strip_code(read_utf8(f))
    content <- paste(code, collapse = "\n")
    hits <- regmatches(
      content,
      gregexpr("[A-Za-z][A-Za-z0-9.]*(?=::)", content, perl = TRUE)
    )
    used <- c(used, unlist(hits))
  }
  used_all <- unique(used)

  # unused: declared but never referenced (keep base pkgs in the comparison so
  # a legitimately-used base import like tools:: is not flagged as unused)
  unused <- setdiff(declared, used_all)

  # undeclared: referenced but not in Imports/Suggests (base pkgs are always
  # available, so they never need declaring)
  undeclared <- setdiff(
    setdiff(used_all, base_pkgs),
    c(declared, parse_pkgs(desc, "Suggests"))
  )

  warnings <- if (length(unused))
    sprintf("Remove from Imports (unused): %s", unused) else character(0)
  errors <- if (length(undeclared))
    sprintf("Add to Imports (used but undeclared): %s", undeclared) else character(0)

  res <- rpf_report("check_imports()", errors, warnings)
  res$unused     <- unused
  res$undeclared <- undeclared
  invisible(res)
}
