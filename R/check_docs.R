#' Find Documentation Gaps in Exported Functions
#'
#' @description
#' Scans `.R` files for `@export`-ed functions and checks that each has
#' `@param` for every argument, a `@return`, and at least one `@examples`.
#'
#' @param dir Character. Directory containing R source. Defaults to `"R"`.
#'
#' @return Invisibly, a list with `ok`, `errors`, `warnings`, `notes`, and a
#'   `gaps` data frame (`file`, `function_name`, `missing_params`,
#'   `has_return`, `has_examples`).
#'
#' @examples
#' \dontrun{
#' check_docs()
#' }
#' @export
check_docs <- function(dir = "R") {
  assert_package_root()
  if (!dir.exists(dir)) stop(sprintf("Directory '%s' does not exist.", dir), call. = FALSE)

  records  <- parse_r_blocks(r_source_files(dir))
  warnings <- character(0)
  rows     <- list()

  for (r in records) {
    if (!r$exported || r$internal) next

    declared <- {
      pl <- r$roxygen[grepl("^\\s*#' @param", r$roxygen)]
      sub("^\\s*#' @param\\s+([A-Za-z0-9_.]+).*", "\\1", pl)
    }
    missing_params <- setdiff(r$args, declared)
    has_return     <- any(grepl("@return",   r$roxygen))
    has_examples   <- any(grepl("@examples", r$roxygen))

    if (length(missing_params) || !has_return || !has_examples) {
      msgs <- character(0)
      if (length(missing_params))
        msgs <- c(msgs, sprintf("missing @param: %s", paste(missing_params, collapse = ", ")))
      if (!has_return)   msgs <- c(msgs, "missing @return")
      if (!has_examples) msgs <- c(msgs, "missing @examples")
      warnings <- c(warnings, sprintf("%s() - %s", r$name, paste(msgs, collapse = "; ")))
      rows[[length(rows) + 1L]] <- data.frame(
        file           = r$file,
        function_name  = r$name,
        missing_params = paste(missing_params, collapse = ", "),
        has_return     = has_return,
        has_examples   = has_examples,
        stringsAsFactors = FALSE
      )
    }
  }

  res <- rpf_report("check_docs()", warnings = warnings)
  res$gaps <- if (length(rows)) do.call(rbind, rows) else data.frame()
  invisible(res)
}
