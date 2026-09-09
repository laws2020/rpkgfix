test_that("bump_version() dry_run does not change DESCRIPTION", {
  with_fixture({
    before <- readLines("DESCRIPTION")
    bump_version(dry_run = TRUE)
    expect_identical(readLines("DESCRIPTION"), before)
  })
})
