test_that("check_namespace() reports missing NAMESPACE", {
  with_fixture({
    res <- check_namespace()
    expect_false(res$ok)
  })
})
