test_that("check_output() flags cat()/print()", {
  with_fixture(
    r_files = list("foo.R" = 'foo <- function() cat("hi")'),
    code = {
      res <- check_output()
      expect_gt(length(res$warnings), 0L)
    }
  )
})
