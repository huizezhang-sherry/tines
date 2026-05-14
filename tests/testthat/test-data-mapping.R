test_that("update io", {
data_2023 <- data.frame(
  age = c(25, 30, 35, NA, 45),
  income = c(50000, 60000, NA, 70000, 80000),
  city = c("NYC", "LA", "Chicago", "NYC", NA)
)

data_2024 <- data.frame(
  age = c(26, 31, 36, 40, 46),
  salary = c(52000, 62000, 68000, 72000, 82000),  # Note: 'salary' not 'income'
  city = c("NYC", "LA", "Chicago", "Boston", "LA")
)

# Build schema with data attached (validates as steps are added)
schema <- build_schema(data = data_2023) |>
  add_step(
    id = "step-filter",
    fork = "remove missing values",
    path = "exclude rows with NA",
    inputs = c("age", "income"),
    outputs = "df_clean"
  ) |>
  add_step(
    id = "step-transform",
    fork = "log transform income",
    path = "use natural log",
    inputs = "df_clean",
    outputs = "df_transformed"
  )

  schema2 <- update_io(schema, "step-filter",
                    inputs = c("age", "salary", "city"),
                    outputs = "df_clean")
  expect_snapshot(schema)
  expect_snapshot(schema2)
  schema_2024 <- update_data(schema2, data_2024)
  expect_error(update_data(schema, data_2024))
  expect_snapshot(schema_2024)
  

  ## testing for the LLM version is not implemented yet

})


