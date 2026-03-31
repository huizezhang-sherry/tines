library(vcr)

vcr::vcr_configure(
 dir = testthat::test_path("_vcr")
)
