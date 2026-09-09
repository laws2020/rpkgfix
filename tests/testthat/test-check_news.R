test_that("check_news() notes a missing NEWS.md", {
  with_fixture({
    res <- check_news()
    expect_type(res, "list")
    expect_true(res$ok)
  })
})
