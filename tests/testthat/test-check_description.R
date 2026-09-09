test_that("check_description() passes on a clean DESCRIPTION", {
  with_fixture({
    res <- check_description()
    expect_type(res, "list")
    expect_true(res$ok)
  })
})
