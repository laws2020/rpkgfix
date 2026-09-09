test_that("check_encoding() flags non-ASCII bytes", {
  with_fixture(
    r_files = list("foo.R" = "x <- 'caf\u00e9'"),
    code = {
      res <- check_encoding()
      expect_gt(length(res$warnings), 0L)
    }
  )
})
