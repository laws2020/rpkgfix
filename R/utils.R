# Internal helpers for rpkgfix. All base R. None are exported.

#' Assert we are inside an R package root
#' @noRd
assert_package_root <- function(path = ".") {
  if (!file.exists(file.path(path, "DESCRIPTION"))) {
    stop(
      "No DESCRIPTION file found. Run rpkgfix functions from the root of an R package.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Require a suggested package, aborting with a helpful message if absent
#' @noRd
require_suggested <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      sprintf(
        "Package '%s' is required but not installed. Install it with install.packages(\"%s\").",
        pkg, pkg
      ),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Read a file as a character vector, always UTF-8
#' @noRd
read_utf8 <- function(path) {
  readLines(path, encoding = "UTF-8", warn = FALSE)
}

#' Write a character vector to a file, always UTF-8
#' @noRd
write_utf8 <- function(text, path) {
  writeLines(enc2utf8(text), con = path, useBytes = FALSE)
}

#' Parse DESCRIPTION as a named list
#' @noRd
read_desc <- function(path = "DESCRIPTION") {
  as.list(read.dcf(path)[1, , drop = TRUE])
}

#' Split a dependency field (Imports/Suggests/Depends) into package names,
#' stripping version constraints like "(>= 1.0.0)".
#' @noRd
parse_pkgs <- function(desc, field) {
  raw <- desc[[field]]
  if (is.null(raw) || !nzchar(trimws(raw))) return(character(0))
  parts <- strsplit(raw, ",")[[1]]
  parts <- trimws(parts)
  parts <- sub("\\s*\\(.*\\)$", "", parts)   # drop version constraint
  parts <- trimws(parts)
  setdiff(parts[nzchar(parts)], "R")         # R is not a package
}

#' List .R source files in a directory
#' @noRd
r_source_files <- function(dir = "R") {
  if (!dir.exists(dir)) return(character(0))
  list.files(dir, pattern = "\\.[Rr]$", full.names = TRUE)
}

#' Strip comments and quoted strings from source lines so scanners do not
#' match patterns that live inside comments or string literals.
#' @noRd
strip_code <- function(lines) {
  lines <- sub("#.*$", "", lines)                                 # drop comments
  lines <- gsub("\"(\\\\.|[^\"\\\\])*\"", "\"\"", lines, perl = TRUE)  # blank "..."
  lines <- gsub("'(\\\\.|[^'\\\\])*'", "''", lines, perl = TRUE)       # blank '...'
  lines
}

#' Count occurrences of a single literal character in a string
#' @noRd
count_char <- function(s, ch) {
  lengths(regmatches(s, gregexpr(ch, s, fixed = TRUE)))
}

#' Pluralise a suffix based on the length of a vector
#' @noRd
plural <- function(x, suffix = "s") {
  if (length(x) == 1L) "" else suffix
}

# -- Messaging helpers (base-R replacements for cli::) --------------------------

#' @noRd
rpf_h2 <- function(text) {
  message("")
  message("== ", text, " ==")
}

#' @noRd
rpf_rule <- function(left = "", right = "") {
  line <- paste0("-- ", left, " ")
  pad  <- max(0L, 80L - nchar(line) - nchar(right))
  message(line, strrep("-", pad), right)
}

#' @noRd
rpf_info <- function(text) {
  message("i ", text)
}

#' @noRd
rpf_success <- function(text) {
  message("v ", text)
}

#' @noRd
rpf_warn <- function(text) {
  message("! ", text)
}

#' @noRd
rpf_danger <- function(text) {
  message("x ", text)
}

#' Print a bulleted list with a leading symbol per item
#' @noRd
rpf_bullets <- function(items, symbol = "*") {
  for (it in items) message("  ", symbol, " ", it)
}

#' Standard reporting + return contract for every check_* function.
#' Prints a header, then bullets for errors/warnings/notes, and returns
#' invisibly a list(ok, errors, warnings, notes).
#' @noRd
rpf_report <- function(title,
                       errors   = character(0),
                       warnings = character(0),
                       notes    = character(0)) {
  rpf_h2(title)

  if (length(errors)) {
    rpf_danger(sprintf("%d error%s:", length(errors), plural(errors)))
    rpf_bullets(errors, "x")
  }
  if (length(warnings)) {
    rpf_warn(sprintf("%d warning%s:", length(warnings), plural(warnings)))
    rpf_bullets(warnings, "!")
  }
  if (length(notes)) {
    rpf_info(sprintf("%d note%s:", length(notes), plural(notes)))
    rpf_bullets(notes, "*")
  }
  if (!length(errors) && !length(warnings) && !length(notes)) {
    rpf_success("OK - no issues found.")
  }

  invisible(list(
    ok       = length(errors) == 0L,
    errors   = errors,
    warnings = warnings,
    notes    = notes
  ))
}

# -- Roxygen + signature parsing -----------------------------------------------

#' Split the text inside a function signature's parentheses into top-level
#' argument names only. Respects nesting so default values such as
#' c("patch", "minor", "major") or match.arg(...) are NOT split into extra
#' arguments. Returns the identifier to the left of each top-level "=".
#' @noRd
arg_names_from_signature <- function(sig) {
  if (!nzchar(trimws(sig))) return(character(0))

  chars <- strsplit(sig, "", fixed = TRUE)[[1]]
  depth <- 0L
  in_dq <- FALSE
  in_sq <- FALSE
  buf   <- character(0)
  parts <- character(0)

  for (ch in chars) {
    if (in_dq) {
      if (ch == "\"") in_dq <- FALSE
      buf <- c(buf, ch); next
    }
    if (in_sq) {
      if (ch == "'") in_sq <- FALSE
      buf <- c(buf, ch); next
    }
    if (ch == "\"") { in_dq <- TRUE;  buf <- c(buf, ch); next }
    if (ch == "'")  { in_sq <- TRUE;  buf <- c(buf, ch); next }

    if (ch %in% c("(", "[", "{")) depth <- depth + 1L
    if (ch %in% c(")", "]", "}")) depth <- depth - 1L

    if (ch == "," && depth == 0L) {
      parts <- c(parts, paste(buf, collapse = ""))
      buf   <- character(0)
    } else {
      buf <- c(buf, ch)
    }
  }
  parts <- c(parts, paste(buf, collapse = ""))

  # Take the identifier left of "=" (top-level default assignment)
  names_out <- vapply(parts, function(p) {
    nm <- sub("=.*$", "", p)   # everything before the first "=" (already depth 0)
    trimws(nm)
  }, character(1L))

  names_out <- names_out[nzchar(names_out)]
  names_out <- names_out[names_out != "..."]
  unname(names_out)
}

#' Extract argument names from a (possibly multi-line) function signature that
#' starts at line index `i`. Reads forward until parentheses balance.
#' @noRd
extract_signature <- function(lines, i) {
  # Accumulate from the "function(" line until parens balance.
  start <- i
  text  <- lines[[start]]
  # begin counting from the first "(" after "function"
  open_at <- regexpr("function\\s*\\(", text, perl = TRUE)
  if (open_at < 0) return(character(0))

  acc   <- substring(text, open_at + attr(open_at, "match.length") - 1L)
  depth <- count_char(acc, "(") - count_char(acc, ")")
  j     <- start
  while (depth > 0L && j < length(lines)) {
    j   <- j + 1L
    acc <- paste0(acc, "\n", lines[[j]])
    depth <- count_char(acc, "(") - count_char(acc, ")")
  }

  # Pull the content between the outermost parentheses.
  inner <- sub("^\\s*\\(", "", acc)          # drop leading "("
  inner <- sub("\\)\\s*(\\{)?\\s*$", "", inner, perl = TRUE)  # drop trailing ") {"
  # inner may still have trailing body if brace on same line; strip after last
  # top-level ")". Re-derive by trimming at the balancing point:
  arg_names_from_signature(inner)
}

#' Parse .R files into records of roxygen block + function name + args +
#' whether it is exported / internal.
#' @noRd
parse_r_blocks <- function(files) {
  records <- list()

  for (f in files) {
    lines <- read_utf8(f)
    n     <- length(lines)
    i     <- 1L
    roxy  <- character(0)

    while (i <= n) {
      line <- lines[[i]]

      if (grepl("^\\s*#'", line)) {
        roxy <- c(roxy, line)
        i <- i + 1L
        next
      }

      # function definition: name <- function( ... )
      m <- regexec("^\\s*([A-Za-z.][A-Za-z0-9._]*)\\s*(<-|=)\\s*function\\s*\\(",
                   line, perl = TRUE)
      g <- regmatches(line, m)[[1]]

      if (length(g) >= 2L) {
        name <- g[[2]]
        args <- extract_signature(lines, i)

        records[[length(records) + 1L]] <- list(
          file     = f,
          name     = name,
          args     = args,
          roxygen  = roxy,
          exported = any(grepl("@export", roxy)),
          internal = any(grepl("@noRd",   roxy))
        )
        roxy <- character(0)
      } else if (nzchar(trimws(line))) {
        # a non-roxygen, non-def code line resets any dangling block
        roxy <- character(0)
      }

      i <- i + 1L
    }
  }

  records
}
