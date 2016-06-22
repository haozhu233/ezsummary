context("Summary_Categorical")
#####

df <- mtcars %>% group_by(am) %>% select(gear)
df2 <- mtcars %>% group_by(am) %>% select(gear, carb)
df3 <- mtcars %>% select(gear)

test_that("ezsummary_c can't work with grouping data", {
  expect_equivalent(names(ezsummary_categorical(df3)),
               expected = c("variable", "count", "p"))
  expect_equivalent(names(ezsummary_categorical(df3, n = T)),
               expected = c("variable", "n", "count", "p"))
  expect_equivalent(ezsummary_categorical(df3)[2],
               expected = structure(
                 list(count = c(15L, 12L, 5L)),
                 class = c("tbl_df", "tbl", "data.frame"),
                 row.names = 1:3
               ))
  expect_equivalent(ezsummary_categorical(df3, n = T)[2:3],
               expected = structure(
                 list(n = c(32L, 32L, 32L), count = c(15L, 12L, 5L)),
                 class = c("tbl_df", "tbl", "data.frame"),
                 row.names = 1:3
               ))
})

test_that("ezsummary_c can't rename the variables for data with grouping info",
          {
            expect_equivalent(names(ezsummary_categorical(df2))[2],
                              expected = c("variable"))
            expect_equivalent(names(ezsummary_categorical(df2, n = T))[2:3],
                              expected = c("variable", "n"))
            expect_equivalent(as.character(ezsummary_categorical(df2)[2, 2]),
                              expected = c("gear_4"))
            expect_equivalent(
              as.character(ezsummary_categorical(df2, n = T)[2, 2:3]),
              expected = c("gear_4", "19"))
          })
