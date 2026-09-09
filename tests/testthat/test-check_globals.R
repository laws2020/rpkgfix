test_that("check_globals() degrades gracefully when pkg is not loadable", {
  with_fixture({
    res <- check_globals(pkg = "an.unloadable.pkg.name")
    expect_type(res, "list")
    expect_true(res$ok)  # degrades to a note, not an error
  })
})
