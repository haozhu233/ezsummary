context("Summary_Quantitative")
#####

df <- mtcars %>% select(mpg)
df2 <- mtcars %>% group_by(am) %>% select(mpg)
df3 <- mtcars %>% select(mpg, hp)
df4 <- mtcars %>% group_by(am) %>% select(mpg, hp)
df5 <- data.frame(x=c(-2,2,0,NA), y=c(1,1,1,1))

test_that("ezsummary_quantitative can work correctly with 1 variable and no grouping data", {
  expected_data_frame_no_N <- data.frame(variable = "mpg", mean = 20.091, sd = 6.027)
  expected_data_frame_N <- data.frame(variable = "mpg", n=32, mean = 20.091, sd = 6.027)

  expect_equivalent(ezsummary_quantitative(df), expected = expected_data_frame_no_N)
  expect_equivalent(ezsummary_quantitative(df, n = T), expected = expected_data_frame_N)
})

test_that("ezsummary_quantitative can evaluate grouping info correctly with 1 variable", {
  expect_equal(names(ezsummary_quantitative(df2)), expected = c("am", "variable", "mean", "sd"))
  expect_equal(names(ezsummary_quantitative(df2, n=T)), expected = c("am", "variable", "n", "mean", "sd"))
  expect_equivalent(as.data.frame(ezsummary_quantitative(df2)[,1]), expected = data.frame(am = 0:1))
  expect_equivalent(as.data.frame(ezsummary_quantitative(df2, n = T)[,1]), expected = data.frame(am = 0:1))
})

test_that("ezsummary_quantitative can work with 2 variables", {
  expect_equal(names(ezsummary_quantitative(df3)), expected = c("variable", "mean", "sd"))
  expect_equal(names(ezsummary_quantitative(df3, n=T)), expected = c("variable", "n", "mean", "sd"))
  expect_equivalent(as.data.frame(ezsummary_quantitative(df3)[,1]), expected = data.frame(x = c("mpg", "hp")))
  expect_equivalent(as.data.frame(ezsummary_quantitative(df3, n = T)[,1]), expected = data.frame(x = c("mpg", "hp")))
})

test_that("ezsummary_quantitative can work with 2 variables with grouping info", {
  expect_equal(names(ezsummary_quantitative(df4)), expected = c("am", "variable", "mean", "sd"))
  expect_equal(names(ezsummary_quantitative(df4, n=T)), expected = c("am", "variable", "n", "mean", "sd"))
  expect_equivalent(as.data.frame(ezsummary_quantitative(df4)[,1:2]), expected = data.frame(am = c(0,1, 0, 1), x = c("mpg","mpg", "hp", "hp")))
  expect_equivalent(as.data.frame(ezsummary_quantitative(df4, n = T)[,1:2]), expected = data.frame(am = c(0,1, 0, 1), x = c("mpg","mpg", "hp", "hp")))
})

test_that("ezsummary_quantitative can handle NAs when running with quantile=TRUE", {
  expect_equivalent(
    df5 %>% group_by(y) %>% ezsummary(quantile = TRUE) %>%
    select(q0,q25,q50,q75,q100),
    expected = structure(
      list(q0 = -2, q25 = -1, q50 = 0, q75 = 1, q100 = 2),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = as.integer(1)
    ))
})
