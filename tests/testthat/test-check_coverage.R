test_that("check_coverage() flags functions with no test reference", {
  with_fixture(
    r_files = list("foo.R" = c("#' @export", "foo <- function() 1")),
    code = {
      res <- check_coverage()
      expect_true("foo" %in% res$warnings || length(res$warnings) > 0L)
    }
  )
})
