test_that("diagnose() aggregates check results", {
  with_fixture(
    r_files = list("foo.R" = c("#' @export", "foo <- function() 1")),
    code = {
      res <- diagnose()
      expect_type(res, "list")
      expect_true(!is.null(res$results))
    }
  )
})
