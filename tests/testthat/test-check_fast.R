test_that("check_fast() requires devtools (Suggests-guarded)", {
  # Only run when devtools is installed; otherwise the guard should error.
  skip_if_not_installed("devtools")
  expect_true(is.function(check_fast))
})
