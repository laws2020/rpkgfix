test_that("check_side_effects() flags library() calls", {
  with_fixture(
    r_files = list("foo.R" = 'foo <- function() library(stats)'),
    code = {
      res <- check_side_effects()
      expect_gt(length(res$warnings), 0L)
    }
  )
})
