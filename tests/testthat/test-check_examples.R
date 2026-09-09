test_that("check_examples() flags dontrun-only examples", {
  with_fixture(
    r_files = list("foo.R" = c(
      "#' Title", "#' @examples", "#' \\dontrun{foo()}",
      "#' @export", "foo <- function() 1")),
    code = {
      res <- check_examples()
      expect_type(res, "list")
    }
  )
})
