#' rpkgfix: Diagnose and Fix Common R Package Problems
#'
#' @description
#' `rpkgfix` is a dependency-light toolkit for R package authors. It is built
#' almost entirely on base R and splits its functions into two clear groups:
#'
#' - **`check_*()`** functions are *read-only* diagnostics. They never modify
#'   files and each returns an invisible list of `errors`, `warnings`, and
#'   `notes` so they can be used programmatically (e.g. in CI).
#' - **Mutating helpers** (verb-first names such as `add_namespaces()`,
#'   `fix_buildignore()`, `bump_version()`, `clean_build()`) write to disk.
#'
#' @section Diagnostics:
#' | Function | Purpose |
#' |---|---|
#' | [check_description()] | DESCRIPTION field hygiene |
#' | [check_license()] | LICENSE vs DESCRIPTION consistency |
#' | [check_imports()] | Declared imports vs actual `pkg::` usage |
#' | [check_docs()] | Missing `@param`/`@return`/`@examples` |
#' | [check_namespace()] | NAMESPACE vs `@export` drift |
#' | [check_globals()] | Undefined global variables |
#' | [check_encoding()] | Non-ASCII characters |
#' | [check_style()] | Anti-patterns (`T`/`F`, `sapply()`, `1:length(x)`) |
#' | [check_examples()] | Examples entirely wrapped in `\dontrun{}` |
#' | [check_coverage()] | Exported functions with no test reference |
#' | [check_spelling()] | Spell-check DESCRIPTION/`.Rd` |
#' | [check_output()] | `cat()`/`print()` in package code |
#' | [check_side_effects()] | `library()`/`require()`/`installed.packages()` in `R/` |
#' | [check_deps()] | Recursive dependency weight |
#' | [check_news()] | NEWS entry matches DESCRIPTION version |
#'
#' @keywords internal
"_PACKAGE"
