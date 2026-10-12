test_that("prompt_extract_schema formats correctly", {
  data_dict <- c("var1", "var2", "var3")
  text <- "Some methodology text."

  result <- prompt_extract_schema(data_dict, text)
  expect_snapshot(cat(result))
})
