<!-- README.md is generated from README.Rmd. Please edit that file -->
ezsummary
=========

[![Build Status](https://travis-ci.org/haozhu233/ezsummary.svg?branch=master)](https://travis-ci.org/haozhu233/ezsummary)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/ezsummary)](http://cran.r-project.org/package=ezsummary)
[![Coverage Status](https://coveralls.io/repos/github/haozhu233/ezsummary/badge.svg?branch=master)](https://coveralls.io/github/haozhu233/ezsummary?branch=master)

Introduction
------------

Hadley's [`dplyr`](https://github.com/hadley/dplyr) provides a grammar to talk about data manipulation and another his package, [`tidyr`](https://github.com/hadley/tidyr) provides a mindset to think about data. These two tools really makes it a lot easier to perform data manipulation today. This package `ezsummary` packed up some commonly used `dplyr` and `tidyr` steps to generate data summarization to help you save some typing time. It also comes with some table decoration tolls that basically allows you to pipe the results directly into a table generating function like `knitr::kable()` to render out.

For example, if you only use `dplyr` and `tidyr` to generate a statistical summary table by group. You need to go through the following steps.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(tidyr)

mtcars %>%
  select(cyl, mpg, wt, hp) %>%
  group_by(cyl) %>%
  summarize_each(funs(mean, sd)) %>%
  gather(variable, value, -cyl) %>%
  mutate(value = round(value, 3)) %>%
  separate(variable, into = c("variable", "analysis")) %>%
  spread(analysis, value) %>%
  mutate(variable = factor(variable, levels = c("mpg", "wt", "hp"))) %>%
  arrange(variable, cyl) %>%
  kable()
```

|  cyl| variable |     mean|      sd|
|----:|:---------|--------:|-------:|
|    4| mpg      |   26.664|   4.510|
|    6| mpg      |   19.743|   1.454|
|    8| mpg      |   15.100|   2.560|
|    4| wt       |    2.286|   0.570|
|    6| wt       |    3.117|   0.356|
|    8| wt       |    3.999|   0.759|
|    4| hp       |   82.636|  20.935|
|    6| hp       |  122.286|  24.260|
|    8| hp       |  209.214|  50.977|

For people who are familar with "tidyverse", I'm sure the above codes are very straightforward. However, it's a bit annoying to type it again and again. With `ezsummary`, you don't need to think too much about it. You can just type:

``` r
library(ezsummary)

mtcars %>%
  select(cyl, mpg, wt, hp) %>%
  group_by(cyl) %>%
  ezsummary() %>%
  kable()
```

|  cyl| variable |     mean|      sd|
|----:|:---------|--------:|-------:|
|    4| mpg      |   26.664|   4.510|
|    6| mpg      |   19.743|   1.454|
|    8| mpg      |   15.100|   2.560|
|    4| wt       |    2.286|   0.570|
|    6| wt       |    3.117|   0.356|
|    8| wt       |    3.999|   0.759|
|    4| hp       |   82.636|  20.935|
|    6| hp       |  122.286|  24.260|
|    8| hp       |  209.214|  50.977|

To install
----------

``` r
    install.packages("ezsummary")
```

Or

``` r
    install.packages("devtools")
    devtools::install_github("haozhu233/ezsummary")
```

To use
------

Here, I will show another quick demo of how to use this package here. For detailed package documentation, please check the [package vignette](http://rpubs.com/haozhu233/ezsummary0_2_0).

``` r
library(dplyr)
library(ezsummary)

mtcars %>%
  # q: quantitative/continuous variables; c: categorical variables
  var_types("qcqqqqqcccc") %>%
  group_by(am) %>%
  ezsummary(flavor = "wide", unit_markup = "[. (.)]",
            digits = 1, p_type = "percent") %>%
  kable(col.names = c("variable", "Manual", "Automatic"))
```

| variable | Manual        | Automatic    |
|:---------|:--------------|:-------------|
| mpg      | 17.1 (3.8)    | 24.4 (6.2)   |
| cyl\_4   | 3 (15.8%)     | 8 (61.5%)    |
| cyl\_6   | 4 (21.1%)     | 3 (23.1%)    |
| cyl\_8   | 12 (63.2%)    | 2 (15.4%)    |
| disp     | 290.4 (110.2) | 143.5 (87.2) |
| hp       | 160.3 (53.9)  | 126.8 (84.1) |
| drat     | 3.3 (0.4)     | 4 (0.4)      |
| wt       | 3.8 (0.8)     | 2.4 (0.6)    |
| qsec     | 18.2 (1.8)    | 17.4 (1.8)   |
| vs\_0    | 12 (63.2%)    | 6 (46.2%)    |
| vs\_1    | 7 (36.8%)     | 7 (53.8%)    |
| gear\_3  | 15 (78.9%)    | 0 (0)        |
| gear\_4  | 4 (21.1%)     | 8 (61.5%)    |
| gear\_5  | 0 (0)         | 5 (38.5%)    |
| carb\_1  | 3 (15.8%)     | 4 (30.8%)    |
| carb\_2  | 6 (31.6%)     | 4 (30.8%)    |
| carb\_3  | 3 (15.8%)     | 0 (0)        |
| carb\_4  | 7 (36.8%)     | 3 (23.1%)    |
| carb\_6  | 0 (0)         | 1 (7.7%)     |
| carb\_8  | 0 (0)         | 1 (7.7%)     |

Issues
------

If you ever find any issues, please feel free to report it in the issues tracking part on github. <https://github.com/haozhu233/simple.summary/issues>.

Thanks for using this package!
