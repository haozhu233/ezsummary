<!-- README.md is generated from README.Rmd. Please edit that file -->
ezsummary
=========

Travis CI: [![Build Status](https://travis-ci.org/haozhu233/ezsummary.svg?branch=master)](https://travis-ci.org/haozhu233/ezsummary)
CRAN: [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/ezsummary)](http://cran.r-project.org/package=ezsummary)
Test Coverage: [![Coverage Status](https://coveralls.io/repos/haozhu233/ezsummary/badge.svg?branch=master&service=github)](https://coveralls.io/github/haozhu233/ezsummary?branch=master)
[![Join the chat at https://gitter.im/haozhu233/ezsummary](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/haozhu233/ezsummary?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Introduction
------------

Hadley's `dplyr` is very powerful and the "ecosystem" around it, such as `reshape2` and `tidyr`, makes it even better. However, there is still a short distance between the direct outputs of `dplyr` and something can be used directly in `Shiny` or `rmarkdown`. Basically, the concept of this package is kind of similar with the concept of David Robinson's `broom` package but this one focuses on the summary part.

When we are talking about statistical summary, there are always two types of data: quantitative (continuous) and qualitative (categorical). As your college Stats class may have told you, the common ways we used to look at these two types of data are different. For quantitative data, we want to know the mean, standard deviation and some other things while for categorical data, we want to know the number of items in each category and the percentage.

As investigators or data scientists, we are encountering these two kinds of data everyday. The traditional way is to do the analyses separately and spend some time later on "gluing" the results together. Believe me or not, this step actually takes a lot of time especially if you are doing it everyday.

This package addresses this issue by pre-programming the common summary task in a way that "makes sense" and offers tools to help you format your table in a easier way. It is depends on `dplyr` and `reshape2`, so it's very fast. Also, this package uses `dplyr`'s piping syntax and the functions inside this package can interact with other `dplyr` functions pretty well. You will feel codes flow out of your fingertips after you get used to it.

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

### Basics

First of all, in this package, I use **q** to stand for "quantitative" and **c** to stand for "categorical" instead of the reverse way. The reason is simple: "quantitative" gives 112 million google results while "qualitative" only gives me 67 million. (I hope there could be better ways to make these two terms more distinctive but "continuous" vs "categorical"? really?...)

The major functions in `ezsummary` include

-   **`ezsummary`**
-   `ezsummary_categorical`
-   `ezsummary_quantitative`
-   `var_types`
-   **`ezmarkup`**

Both `ezsummary_categorical` (shorthand `ezsummary_c()`) and `ezsummar_quantitative` (shorthand `ezsummary_q()`) can be used independently. By default, `ezsummary_categorical` will give you the count and proportion of each category. If you want to know total counts, you will need to set the option `n = T`. If you want to display Percentage instead of proportion, you will need to disable proportion by `p = F` and enable Percentage by `P = T`. Similarly, `ezsummary_quantitative` works in the same way but it has more options, including standard error of the mean(SEM) `sem`, `median` and `quantile`. You can adjust the rounding by using `round.N`. Here are two examples using our beloved `mtcars`.

``` r
library(dplyr)
library(tidyr)
library(ezsummary)
library(knitr)

mtcars %>%
  select(am, cyl) %>%
  ezsummary_c(n=T) %>%
  kable()
```

| variable |    n|  count|      p|
|:---------|----:|------:|------:|
| am\_0    |   32|     19|  0.594|
| am\_1    |   32|     13|  0.406|
| cyl\_4   |   32|     11|  0.344|
| cyl\_6   |   32|      7|  0.219|
| cyl\_8   |   32|     14|  0.438|

``` r

mtcars %>%
  group_by(am) %>%
  select(mpg, wt, hp) %>%
  ezsummary_q(sd = F, sem = T, digits = 1) %>%
  kable()
```

|   am| variable |   mean|   sem|
|----:|:---------|------:|-----:|
|    0| mpg      |   17.1|   0.9|
|    1| mpg      |   24.4|   1.7|
|    0| wt       |    3.8|   0.2|
|    1| wt       |    2.4|   0.2|
|    0| hp       |  160.3|  12.4|
|    1| hp       |  126.8|  23.3|

### Advanced

If you are doing analyses by group, like the example above, by the default setting of `ezsummary`, you will get a "tidy" formated table of results, in which the grouping information are listed as column(s) on the left. This format allows you to keep process your results. If you want the grouping information to be organized into row.names and makes the table wider, which is more "publish ready", you should use the `flavor` option. There are two options available, "long" and "wide".

``` r
mtcars %>%
  group_by(am) %>%
  select(mpg, wt, hp) %>%
  ezsummary_q(sd = F, sem = T, digits = 1, flavor = "wide") %>%
  kable()
```

| variable |  am.0\_mean|  am.0\_sem|  am.1\_mean|  am.1\_sem|
|:---------|-----------:|----------:|-----------:|----------:|
| mpg      |        17.1|        0.9|        24.4|        1.7|
| wt       |         3.8|        0.2|         2.4|        0.2|
| hp       |       160.3|       12.4|       126.8|       23.3|

(You may have notived that I'm using dot to separate grouping variable name and option and using underscore to separate grouping info and stats names. As as result, it will be a little easier for people who are not that familar with `regex` to cut the names and reshape the results.)

Now you feel like it is not that easy to read mean and sem on the same row. Well, we have `ezmarkup`. In this function, we use a dot `.` to represent a column and use a pair of bracket `[]` to represent you want to **"squeeze"** the columns inside into one. Any other symbols and characters within a pair of bracket will be copied into the same cell as well. It allows us to do advanced formatting settings in a very convenient way. Also, if you use the `unit_markup` option within the `ezsummary` functions, it will give you the same results. In that case, instead of typing in the markup pattern for every column, you just need to type the pattern for each pair of analysis you want to do. Here are two examples.

``` r
mtcars %>%
  group_by(am) %>%
  select(mpg, wt, hp) %>%
  ezsummary_quantitative(sd = F, sem = T, digits = 1, 
                         flavor = "wide") %>%
  ezmarkup(".[. (.)][. (.)]") %>%
  kable()
```

| variable | am.0\_mean (am.0\_sem) | am.1\_mean (am.1\_sem) |
|:---------|:-----------------------|:-----------------------|
| mpg      | 17.1 (0.9)             | 24.4 (1.7)             |
| wt       | 3.8 (0.2)              | 2.4 (0.2)              |
| hp       | 160.3 (12.4)           | 126.8 (23.3)           |

``` r

mtcars %>%
  group_by(am) %>%
  select(mpg, wt, hp) %>%
  ezsummary_quantitative(
    sd = F, sem = T, round.N = 1, 
    flavor = "wide", unit_markup = "[. <sub>.</sub>]") %>%
  kable(escape = F)
#> Warning in ezsummary_quantitative(., sd = F, sem = T, round.N = 1, flavor =
#> "wide", : Option round.N has been deprecated. Please use 'digits' instead.
```

| variable | am.0\_mean <sub>am.0\_sem</sub> | am.1\_mean <sub>am.1\_sem</sub> |
|:---------|:--------------------------------|:--------------------------------|
| mpg      | 17.1 <sub>0.9</sub>             | 24.4 <sub>1.7</sub>             |
| wt       | 3.8 <sub>0.2</sub>              | 2.4 <sub>0.2</sub>              |
| hp       | 160.3 <sub>12.4</sub>           | 126.8 <sub>23.3</sub>           |

### Easy Summary

Finally, here comes our `ezsummary` function. By default, `ezsummary` acts just like a regular `ezsummary_quantitative` function, except when a column is not numeric, it will treat that colum as a categorical variable. As a result, `ezsummary` is supposed to be workable in any cases and can successfully reduce the chance of getting embarrassed by applying `mean` on a column of names. To make it better, you can pass a string of data types to `ezsummary` by using the `var_types` function. Again, read after me, "q" stands for a qualitative and continuous variable while "c" stands for a categorical and qualitative variable. Another thing you should pay attention is that the grouping variable should also take a slot. You are recommended to assign it as a categorical variable. Here are two examples.

``` r
mtcars %>% 
  mutate(am = as.character(am)) %>% 
  ezsummary(unit_markup = "[. (.)]") %>%
  kable()
```

| variable | mean (sd)/count (p) |
|:---------|:--------------------|
| mpg      | 20.091 (6.027)      |
| cyl      | 6.188 (1.786)       |
| disp     | 230.722 (123.939)   |
| hp       | 146.688 (68.563)    |
| drat     | 3.597 (0.535)       |
| wt       | 3.217 (0.978)       |
| qsec     | 17.849 (1.787)      |
| vs       | 0.438 (0.504)       |
| am\_0    | 19 (0.594)          |
| am\_1    | 13 (0.406)          |
| gear     | 3.688 (0.738)       |
| carb     | 2.812 (1.615)       |

``` r

mtcars %>% 
  group_by(am) %>%
  select(mpg, cyl, disp, hp, vs) %>%
  var_types("cqcqqc") %>%
  ezsummary(unit_markup = "[. (.)]", flavor="wide", digits = 2) %>%
  kable()
```

| variable | am.0\_mean (am.0\_sd)/p) | am.1\_mean (am.1\_sd)/p) |
|:---------|:-------------------------|:-------------------------|
| mpg      | 17.15 (3.83)             | 24.39 (6.17)             |
| cyl\_4   | 3 (0.16)                 | 8 (0.62)                 |
| cyl\_6   | 4 (0.21)                 | 3 (0.23)                 |
| cyl\_8   | 12 (0.63)                | 2 (0.15)                 |
| disp     | 290.38 (110.17)          | 143.53 (87.2)            |
| hp       | 160.26 (53.91)           | 126.85 (84.06)           |
| vs\_0    | 12 (0.63)                | 6 (0.46)                 |
| vs\_1    | 7 (0.37)                 | 7 (0.54)                 |

A comparison with the code you need to write using `dplyr` and `tidyr`

``` r
mtcars %>%
  group_by(cyl) %>%
  select(mpg, disp, hp, wt) %>% 
  summarize_each(funs(mean, sd)) %>% 
  gather(var, value, -cyl) %>% 
  separate(var, into = c("var", "analysis")) %>% 
  spread(analysis, value) %>% 
  mutate(var = factor(var, levels = c("mpg", "disp", "hp", "wt"))) %>% 
  arrange(var, cyl)
#> Source: local data frame [12 x 4]
#> 
#>      cyl    var       mean         sd
#>    <dbl> <fctr>      <dbl>      <dbl>
#> 1      4    mpg  26.663636  4.5098277
#> 2      6    mpg  19.742857  1.4535670
#> 3      8    mpg  15.100000  2.5600481
#> 4      4   disp 105.136364 26.8715937
#> 5      6   disp 183.314286 41.5624602
#> 6      8   disp 353.100000 67.7713236
#> 7      4     hp  82.636364 20.9345300
#> 8      6     hp 122.285714 24.2604911
#> 9      8     hp 209.214286 50.9768855
#> 10     4     wt   2.285727  0.5695637
#> 11     6     wt   3.117143  0.3563455
#> 12     8     wt   3.999214  0.7594047
```

Issues
------

If you ever find any issues, please feel free to report it in the issues tracking part on github. <https://github.com/haozhu233/simple.summary/issues>.

Thanks for using this package!
