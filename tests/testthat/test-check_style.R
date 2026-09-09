test_that("check_style() flags T/F and sapply", {
  with_fixture(
    r_files = list("foo.R" = c("x <- T", "y <- sapply(1:3, identity)")),
    code = {
      res <- check_style()
      expect_gt(length(res$warnings), 0L)
    }
  )
})
