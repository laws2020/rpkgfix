test_that("add_namespaces() dry_run does not write files", {
  with_fixture(
    r_files = list("foo.R" = 'x <- setNames(1, "a")'),
    code = {
      before <- readLines(file.path("R", "foo.R"))
      add_namespaces(dry_run = TRUE)
      expect_identical(readLines(file.path("R", "foo.R")), before)
    }
  )
})
