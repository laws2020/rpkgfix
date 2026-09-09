test_that("fix_buildignore() dry_run does not write .Rbuildignore", {
  with_fixture({
    fix_buildignore(dry_run = TRUE)
    expect_false(file.exists(".Rbuildignore"))
  })
})
