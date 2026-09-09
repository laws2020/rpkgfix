# tests/testthat/helper-fixture.R
with_fixture <- function(code,
                         desc = NULL,
                         r_files = list(),
                         extra = list()) {
  tmp <- withr::local_tempdir()

  if (is.null(desc)) {
    desc <- c(
      "Package: mypkg",
      "Title: A Test Package",
      "Version: 0.1.0",
      "Description: Does things.",
      "License: MIT + file LICENSE",
      "Authors@R: person('A', 'B', role = c('aut','cre'), email = 'a@b.com')",
      "Encoding: UTF-8"
    )
  }
  writeLines(desc, file.path(tmp, "DESCRIPTION"))

  dir.create(file.path(tmp, "R"))
  for (nm in names(r_files)) writeLines(r_files[[nm]], file.path(tmp, "R", nm))
  for (nm in names(extra))   writeLines(extra[[nm]],   file.path(tmp, nm))

  withr::with_dir(tmp, code)
}
