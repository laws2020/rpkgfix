test_that("clean_build() dry_run does not delete files", {
  with_fixture(
    extra = list(".RData" = "x"),
    code = {
      clean_build(dry_run = TRUE)
      expect_true(file.exists(".RData"))
    }
  )
})
