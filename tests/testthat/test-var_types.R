context("var_type")
#####

df1 <- mtcars

test_that("var_types will only react to data.frame(including data.table)", {
  expect_error(var_type(NULL, "c"), "Please supply a data.frame/data.table as the value of tbl")
  expect_error(var_type("ABC", "c"), "Please supply a data.frame/data.table as the value of tbl")
  expect_error(var_type(1:10, "c"), "Please supply a data.frame/data.table as the value of tbl")
  expect_error(var_type(list(1,2), "c"), "Please supply a data.frame/data.table as the value of tbl")
  expect_error(var_type(list(1:10,"a"), "c"), "Please supply a data.frame/data.table as the value of tbl")
})

# test_that("var_types will throw error when the length of 'types' doesn't match up", {
#   expect_error(var_type(mtcars, "qqqqqqc"), "The length of the string you entered doesn't match the number of variables (excluding grouping variables)")
#   expect_error(var_type(group_by(mtcars, am), "qcqqqqqcccc"), "The length of the string you entered doesn't match the number of variables (excluding grouping variables)")
# })

# test_that("var_types will throw error when the 'types' string contains characters other than 'q' and 'c'", {
#   expect_error(var_type(mtcars, "qcqqqqqcccw"), 'Error in var_type(mtcars, "qcqqqqqcccw") : \n  Unrecognizable character(s) detected!! Please review your input and use "q" and "c" to denote quantitative and categorical variables. \n')
#   expect_error(var_type(group_by(mtcars, am), "qcqqqqqcccc"), "The length of the string you entered doesn't match the number of variables (excluding grouping variables)")
# })
