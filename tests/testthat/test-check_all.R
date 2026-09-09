test_that("check_all() is available and returns a list", {
  with_fixture(
    r_files = list("foo.R" = c("#' @export", "foo <- function() 1")),
    code = {
      res <- check_all()
      expect_type(res, "list")
    }
  )
})
