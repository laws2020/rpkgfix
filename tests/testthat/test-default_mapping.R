test_that("default_mapping() returns a named list", {
  m <- default_mapping()
  expect_type(m, "list")
  expect_true(length(names(m)) > 0L)
})
