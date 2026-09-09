test_that("check_deps() errors on a non-character pkg", {
  expect_error(check_deps(123), "single package name")
})
