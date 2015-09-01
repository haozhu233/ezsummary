context("var_type")
#####

df1 <- mtcars

test_that("var_type will only react to data.frame(including data.table)", {
  expect_error(var_type(NULL, "c"), "Please supply a data.frame/data.table as the value of tbl")
  expect_error(var_type("ABC", "c"), "Please supply a data.frame/data.table as the value of tbl")
  expect_error(var_type(1:10, "c"), "Please supply a data.frame/data.table as the value of tbl")
  expect_error(var_type(list(1,2), "c"), "Please supply a data.frame/data.table as the value of tbl")
  expect_error(var_type(list(1:10,"a"), "c"), "Please supply a data.frame/data.table as the value of tbl")
})

test_that("var_type will throw error when the length of 'types' doesn't match up", {
  expect_error(var_type(mtcars, "qqqqqqc"), "The length of the string you entered doesn't match the number of variables \\(excluding grouping variables\\)")
  expect_error(var_type(group_by(mtcars, am), "qcqqqqqcccc"), "The length of the string you entered doesn't match the number of variables \\(excluding grouping variables\\)")
})

test_that("var_type will throw error when the 'types' string contains characters other than 'q' and 'c'", {
  expect_error(var_type(mtcars, "qcqqqqqcccw"), 'Unrecognizable character\\(s\\) detected!! Please review your input and use "q" and "c" to denote quantitative and categorical variables')
})

test_that("var_type can add the desired contents to the attribute of the data.frame", {
  expect_equal(attributes(var_type(mtcars, "qcqqqqqcccc"))$var_types, expected = c("q", "c", "q", "q", "q", "q", "q", "c", "c", "c", "c"))
})

test_that("var_types_are can do the same thing as var_type", {
  expect_equal(attributes(var_types_are(mtcars, "qcqqqqqcccc"))$var_types, expected = c("q", "c", "q", "q", "q", "q", "q", "c", "c", "c", "c"))
})

test_that("enchant can do the same thing as var_type", {
  expect_equal(attributes(enchant(mtcars, "qcqqqqqcccc"))$var_types, expected = c("q", "c", "q", "q", "q", "q", "q", "c", "c", "c", "c"))
})
