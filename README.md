
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rpkgfix <img src="man/figures/logo.png" align="right" height="139" alt="" />

> **R Package Fixer** – Diagnose and Fix Common R Package Problems

<!-- badges: start -->

[![R-CMD-check](https://github.com/laws2020/rpkgfix/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laws2020/rpkgfix/actions/workflows/R-CMD-check.yaml)  
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)  
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)  
<!-- badges: end -->

------------------------------------------------------------------------

## About

**rpkgfix** is a dependency-light developer toolkit that diagnoses and
fixes  
the most repetitive and error-prone problems in R package development.
It  
catches the cheap `R CMD check` rejections – DESCRIPTION hygiene,
NAMESPACE  
drift, non-ASCII characters, style anti-patterns, missing docs,
coverage  
gaps – *before* you spend minutes running a full check.

Two design principles:

- **Dependency-light.** The runtime `Imports` are only base-priority
  packages  
  (`tools`, `utils`, `stats`). Development-only tools such as `devtools`
  live  
  in `Suggests` and are guarded at call time, so `rpkgfix` never forces
  a heavy  
  dependency tree onto your library.  
- **Diagnose vs. fix split.** Read-only `check_*()` functions never
  touch your  
  files; mutating helpers write to disk and always support
  `dry_run = TRUE`.

> `rpkgfix` is a fast pre-filter, not a replacement for
> `devtools::check()`.  
> Its checks scan source text; only a real `R CMD check` parses and
> installs  
> the package.

------------------------------------------------------------------------

## How It Works

Every `check_*()` diagnostic returns the same invisible contract, so
results  
compose cleanly in CI and inside `check_all()`:

``` r
list(  
  ok       = TRUE,          # logical: did the check pass?  
  errors   = character(0),  # blocking issues (fix before R CMD check)  
  warnings = character(0),  # should-fix issues (review before CRAN)  
  notes    = character(0)   # informational  
)  
```

Some checks add extra fields (e.g. `check_imports()` adds
`unused`/`undeclared`,  
`check_docs()` adds `gaps`, `check_deps()` adds `count`).

------------------------------------------------------------------------

## Installation

``` r
# Install the development version from GitHub  
# install.packages("pak")  
pak::pak("laws2020/rpkgfix")  
```

------------------------------------------------------------------------

## Quick Start

``` r
library(rpkgfix)  
  
# Run the full read-only diagnostic sweep before devtools::check()  
check_all()  
  
# Run a single diagnostic  
check_description()  
check_license()  
  
# Fast, targeted R CMD check pass (skips examples/tests/vignettes)  
check_fast()  
  
# Preview a fix without writing anything, then apply it  
add_namespaces(dry_run = TRUE)  
add_namespaces()  
  
# Populate .Rbuildignore with correctly anchored patterns  
fix_buildignore()  
  
# Bump the version in DESCRIPTION + NEWS.md  
bump_version("patch")  
  
# Remove stale .RData, .Rhistory, tarballs, and build debris  
clean_build(dry_run = TRUE)  
clean_build()  
```

------------------------------------------------------------------------

## The Problem -\> Function Map

| Problem | Function |
|----|----|
| Is my `DESCRIPTION` well-formed? | `check_description()` |
| Does my `LICENSE` match the `License` field? | `check_license()` |
| Do my `Imports` match actual `pkg::` usage? | `check_imports()` |
| Are exported functions missing `@param`/`@return`/`@examples`? | `check_docs()` |
| Is `NAMESPACE` out of sync with `@export` (need to re-document)? | `check_namespace()` |
| Do I have “no visible binding for global variable” issues? | `check_globals()` |
| Are there non-ASCII characters in `R/` or `DESCRIPTION`? | `check_encoding()` |
| Am I using `T`/`F`, `sapply()`, or `1:length(x)`? | `check_style()` |
| Are all my examples wrapped in `\dontrun{}`? | `check_examples()` |
| Which exported functions have no test reference? | `check_coverage()` |
| Are there spelling mistakes in `DESCRIPTION`/`.Rd`? | `check_spelling()` |
| Am I using `cat()`/`print()` instead of `message()`? | `check_output()` |
| Do I call `library()`/`require()`/`installed.packages()` in `R/`? | `check_side_effects()` |
| How heavy is a dependency I’m about to add? | `check_deps()` |
| Does `NEWS.md` have an entry for the current version? | `check_news()` |
| I want to run every diagnostic at once | `check_all()` |

------------------------------------------------------------------------

## Core Functions

### Read-only diagnostics (`check_*`)

These only read and report – they never modify files.

| Function | Description |
|----|----|
| `check_description()` | DESCRIPTION field hygiene (required fields, Title/Description phrasing, version format, `Authors@R`, Imports/Suggests overlap) |
| `check_license()` | LICENSE file vs `License` field consistency; MIT placeholder detection |
| `check_imports()` | Declared `Imports` vs actual `pkg::` usage (adds `unused`/`undeclared`) |
| `check_docs()` | Exported functions missing `@param`/`@return`/`@examples` |
| `check_namespace()` | NAMESPACE drift vs `@export` roxygen tags |
| `check_globals()` | Undefined global variables (suggests `utils::globalVariables()`) |
| `check_encoding()` | Non-ASCII characters in `R/` source and `DESCRIPTION` |
| `check_style()` | Anti-patterns: `T`/`F`, `sapply()`, `1:length(x)` |
| `check_examples()` | Exported functions whose examples are all `\dontrun{}` |
| `check_coverage()` | Exported functions with no corresponding test reference |
| `check_spelling()` | Spell-check `DESCRIPTION`/`.Rd` (aspell/hunspell-style) |
| `check_output()` | `cat()`/`print()` in package code (should be `message()`) |
| `check_side_effects()` | `installed.packages()`/`library()`/`require()` inside `R/` |
| `check_deps()` | Recursive dependency weight (returns a count) |
| `check_news()` | `NEWS.md` has an entry matching current DESCRIPTION version |

### Orchestration

| Function | Description |
|----|----|
| `check_all()` | Runs the full `check_*` suite and prints a consolidated summary |
| `check_fast()` | Fast targeted `R CMD check` pass (skips examples/tests/vignettes) |
| `diagnose()` | Aggregating diagnostic run over the `check_*` suite |

### Mutating fixers (support `dry_run = TRUE`)

These write to disk. Preview with `dry_run = TRUE` first.

| Function | Description |
|----|----|
| `add_namespaces()` | Add `pkg::` prefixes across `R/` using an extensible mapping |
| `fix_buildignore()` | Populate `.Rbuildignore` with correctly anchored patterns |
| `bump_version()` | Bump the version in `DESCRIPTION` and append a `NEWS.md` entry |
| `clean_build()` | Remove stale `.RData`, `.Rhistory`, tarballs, and build debris |
| `default_mapping()` | The default symbol -\> `pkg::` lookup table used by `add_namespaces()` |

------------------------------------------------------------------------

## Typical Workflow

``` r
library(rpkgfix)  
  
# 1. Diagnose everything (read-only, safe)  
check_all()  
  
# 2. Apply the safe, reversible fixes (preview first)  
add_namespaces(dry_run = TRUE)  
add_namespaces()  
fix_buildignore()  
  
# 3. Re-run the fast check for a quick feedback loop  
check_fast()  
  
# 4. Bump the version and record it in NEWS.md  
bump_version("minor")  
  
# 5. Finally, the real thing  
devtools::check()  
```

------------------------------------------------------------------------

## Notes and Caveats

- `check_globals()` requires the package to be loadable; otherwise it
  degrades  
  to a note.  
- `check_style()`’s `T`/`F` rule is heuristic and can false-positive on
  a  
  variable literally named `T`.  
- `check_coverage()` is a name-reference heuristic, not runtime coverage
  –  
  use `covr` for that.  
- `check_namespace()` marks results approximate when `exportPattern()`
  is used.  
- `check_spelling()` degrades to a note when no system spell checker
  is  
  installed.  
- `check_deps()` reads available-repository metadata (a network fetch),
  not  
  your installed library.

------------------------------------------------------------------------

## References

- [rpkgfix on GitHub](https://github.com/laws2020/rpkgfix)  
- [rpkgfix documentation site](https://laws2020.github.io/rpkgfix)  
- [R Packages (2e) – Wickham & Bryan](https://r-pkgs.org)  
- [Writing R
  Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html)

------------------------------------------------------------------------

## License

MIT (c) 2026 Lawrence Garba. See [LICENSE](LICENSE).
