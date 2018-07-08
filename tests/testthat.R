library("testthat")
library("rdefra")

test_check("rdefra")

# Static code analysis using the lintr package
# Integration with lintr: tests to fail if there are any lints in the project
if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Style", {
    lintr::expect_lint_free()
  })
}
