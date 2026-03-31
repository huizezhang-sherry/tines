library(vcr)

vcr::vcr_configure(
  dir = testthat::test_path("fixtures"),
  filter_sensitive_data = list(
    "<<GOOGLE_API_KEY>>" = Sys.getenv("GOOGLE_API_KEY")
  )
)
