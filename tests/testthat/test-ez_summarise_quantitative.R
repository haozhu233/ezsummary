context("Summary_Quantitative")
#####

df <- mtcars %>% select(mpg)
df2 <- mtcars %>% group_by(am) %>% select(mpg)
df3 <- mtcars %>% select(mpg, hp)
df4 <- mtcars %>% group_by(am) %>% select(mpg, hp)

test_that("ez_summarise_quantitative can work correctly with 1 variable and no grouping data", {
  expected_data_frame_no_N <- data.frame(x= "mpg", mean = 20.091, sd = 6.027)
  expected_data_frame_N <- data.frame(x= "mpg", N=32L, mean = 20.091, sd = 6.027)

  expect_equivalent(ez_summarise_quantitative(df), expected = expected_data_frame_no_N)
  expect_equivalent(ez_summarise_quantitative(df, n = T), expected = expected_data_frame_N)
  expect_equivalent(attributes(ez_summarise_quantitative(df))$n.group, expected = 0)
  expect_equivalent(attributes(ez_summarise_quantitative(df))$n.var, expected = 1)
  expect_equivalent(attributes(ez_summarise_quantitative(df, n = T))$n.group, expected = 0)
  expect_equivalent(attributes(ez_summarise_quantitative(df, n = T))$n.var, expected = 1)
})

test_that("ez_summarise_quantitative can evaluate grouping info correctly with 1 variable", {
  expect_equal(names(ez_summarise_quantitative(df2)), expected = c("am", "x", "mean", "sd"))
  expect_equal(names(ez_summarise_quantitative(df2, n=T)), expected = c("am", "x", "N", "mean", "sd"))
  expect_equivalent(as.data.frame(ez_summarise_quantitative(df2)[,1]), expected = data.frame(am = 0:1))
  expect_equivalent(as.data.frame(ez_summarise_quantitative(df2, n = T)[,1]), expected = data.frame(am = 0:1))
  expect_equivalent(attributes(ez_summarise_quantitative(df2))$n.group, expected = 1)
  expect_equivalent(attributes(ez_summarise_quantitative(df2))$n.var, expected = 1)
  expect_equivalent(attributes(ez_summarise_quantitative(df2, n = T))$n.group, expected = 1)
  expect_equivalent(attributes(ez_summarise_quantitative(df2, n = T))$n.var, expected = 1)
})

test_that("ez_summarise_quantitative can work with 2 variables", {
  expect_equal(names(ez_summarise_quantitative(df3)), expected = c("x", "mean", "sd"))
  expect_equal(names(ez_summarise_quantitative(df3, n=T)), expected = c("x", "N", "mean", "sd"))
  expect_equivalent(as.data.frame(ez_summarise_quantitative(df3)[,1]), expected = data.frame(x = c("mpg", "hp")))
  expect_equivalent(as.data.frame(ez_summarise_quantitative(df3, n = T)[,1]), expected = data.frame(x = c("mpg", "hp")))
  expect_equivalent(attributes(ez_summarise_quantitative(df3))$n.group, expected = 0)
  expect_equivalent(attributes(ez_summarise_quantitative(df3))$n.var, expected = 2)
  expect_equivalent(attributes(ez_summarise_quantitative(df3, n = T))$n.group, expected = 0)
  expect_equivalent(attributes(ez_summarise_quantitative(df3, n = T))$n.var, expected = 2)
})

test_that("ez_summarise_quantitative can work with 2 variables with grouping info", {
  expect_equal(names(ez_summarise_quantitative(df4)), expected = c("am", "x", "mean", "sd"))
  expect_equal(names(ez_summarise_quantitative(df4, n=T)), expected = c("am", "x", "N", "mean", "sd"))
  expect_equivalent(as.data.frame(ez_summarise_quantitative(df4)[,1:2]), expected = data.frame(am = c(0,1, 0, 1), x = c("mpg","mpg", "hp", "hp")))
  expect_equivalent(as.data.frame(ez_summarise_quantitative(df4, n = T)[,1:2]), expected = data.frame(am = c(0,1, 0, 1), x = c("mpg","mpg", "hp", "hp")))
  expect_equivalent(attributes(ez_summarise_quantitative(df4))$n.group, expected = 1)
  expect_equivalent(attributes(ez_summarise_quantitative(df4))$n.var, expected = 2)
  expect_equivalent(attributes(ez_summarise_quantitative(df4, n = T))$n.group, expected = 1)
  expect_equivalent(attributes(ez_summarise_quantitative(df4, n = T))$n.var, expected = 2)
})
