test_that("check_license() flags declared file LICENSE with no file", {
  with_fixture({
    res <- check_license()
    expect_type(res, "list")
    expect_false(res$ok)
  })
})
