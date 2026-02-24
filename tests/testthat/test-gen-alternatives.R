test_that("prompt_alternatives wording remains stable (snapshot)", {
  expect_snapshot({prompt_alternatives(block = "clean-missing-data")})
  expect_snapshot({prompt_alternatives("my-target-block", n = 2)})
  expect_snapshot({prompt_alternatives("my-target-block", print = TRUE)})

})
