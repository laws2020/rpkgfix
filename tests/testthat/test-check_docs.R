test_that("check_docs() returns the standard contract", {
  with_fixture(
    r_files = list("foo.R" = c(
      "#' Title", "#' @param x A value", "#' @return A value",
      "#' @examples foo(1)", "#' @export", "foo <- function(x) x")),
    code = {
      res <- check_docs()
      expect_type(res, "list")
      expect_named(res, c("ok", "errors", "warnings", "notes", "gaps"),
                   ignore.order = TRUE)
    }
  )
})
