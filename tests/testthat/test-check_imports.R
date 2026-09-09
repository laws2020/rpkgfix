test_that("check_imports() detects undeclared packages", {
  with_fixture(
    r_files = list("foo.R" = 'x <- fs::dir_ls(".")'),
    desc = c("Package: mypkg", "Title: T", "Version: 0.1.0",
             "Description: D.", "License: MIT", "Encoding: UTF-8",
             "Imports: cli"),
    code = {
      res <- check_imports()
      expect_true("fs" %in% res$undeclared)
    }
  )
})
