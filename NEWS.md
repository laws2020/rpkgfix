# fixer 0.1.0

## New functions

* `prefix_all()` â€” Add `pkg::` namespaces across all R files, with dry-run support and extensible mapping.
* `ignore()` â€” Auto-populate `.Rbuildignore` with correctly anchored regex patterns.
* `is_heavy()` â€” Check recursive dependency count before adding a package to `Imports`.
* `audit()` â€” Fast namespace and global-variable audit via a targeted `R CMD CHECK` pass.
* `bump()` â€” Sync version across `DESCRIPTION`, `NEWS.md`, and `README`.
* `desc_check()` â€” Diagnose common `DESCRIPTION` field problems before `R CMD CHECK`.
* `license_check()` â€” Verify LICENSE file consistency with the `DESCRIPTION` declaration.
* `doc_gaps()` â€” Find exported functions missing `@param`, `@return`, or `@examples`.
* `clean_session()` â€” Remove stale `.RData`, `.Rhistory`, tarballs, and orphaned `.Rd` files.
* `check_imports()` â€” Cross-reference declared `Imports` against actual `pkg::` usage in source.
* `diagnose()` â€” Run the full fixer diagnostic suite in one step.
* `default_mapping()` â€” Exported helper returning the default namespace mapping for `prefix_all()`.
