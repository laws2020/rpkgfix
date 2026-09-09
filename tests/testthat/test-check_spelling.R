test_that("check_spelling() returns the standard contract", {
  with_fixture({
    res <- check_spelling()
    expect_type(res, "list")
    expect_named(res, c("ok", "errors", "warnings", "notes"),
                 ignore.order = TRUE)
  })
})
