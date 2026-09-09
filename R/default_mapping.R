#' Default Namespace Mapping for add_namespaces()
#'
#' @description
#' Returns the built-in lookup table that [add_namespaces()] uses to decide
#' which bare function calls get a `pkg::` prefix. Exported so you can inspect
#' or extend it. This is only a lookup table - it does not add any of these
#' packages as dependencies.
#'
#' @return A named list mapping package names to character vectors of function
#'   names.
#'
#' @examples
#' default_mapping()
#'
#' # Extend it with your own package
#' my_map <- c(default_mapping(), list(purrr = c("map", "walk", "reduce")))
#' @export
default_mapping <- function() {
  list(
    tools = c("file_path_sans_ext", "file_ext", "package_dependencies",
              "toTitleCase"),
    utils = c("packageVersion", "globalVariables", "available.packages",
              "aspell"),
    stats = c("setNames", "aggregate", "median", "na.omit")
  )
}
