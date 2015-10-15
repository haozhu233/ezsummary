<!-- README.md is generated from README.Rmd. Please edit that file -->
ezsummary
=========

Travis CI: [![Build Status](https://travis-ci.org/haozhu233/ezsummary.svg?branch=master)](https://travis-ci.org/haozhu233/ezsummary) Test Coverage: [![Coverage Status](https://coveralls.io/repos/haozhu233/ezsummary/badge.svg?branch=master&service=github)](https://coveralls.io/github/haozhu233/ezsummary?branch=master)

Introduction
------------

Hadley's `dplyr` is very powerful and the "ecosystem" around it, such as `reshape2` and `tidyr`, makes it even better. However, there is still a distance between the direct outputs of `dplyr` and a print-ready tabular display, which can be used directly in `Shiny` or `rmarkdown`. Basically, the concept of this package is kind of similar with the concept of David Robinson's `broom` package but this one is focusing on the summary part.

When we are talking about statistical summary, there are always two types of data: quantitative (continuous) and qualitative (categorical). As your college Stats class may have told you, the common ways we used to look at these two types of data are different. For quantitative data, we want to know the mean, standard deviation and some other things while for categorical data, we want to know the number of items in each category and the percentage.

As investigators or data scientists, we are encountering these two kinds of data everyday. The traditional way is to do the analyses separately and spend some time later on "gluing" the results together. Believe me or not, this step actually takes a lot of time especially if you are doing it everyday.

This package addresses this issue by preprogramming the common summary task in a way that "makes sense" and offers tools to help you format your table in a easier way. It is depends on `dplyr` and `reshape2`, so it's very fast. Also, this package uses `dplyr`'s piping syntax and the functions inside this package can interact with other `dplyr` functions pretty well.

To install
----------

Type

``` r
    install.packages("devtools")
    devtools::install_github("haozhu233/ezsummary")
```

To use
------

First of all, in this package, I use **q** to stand for "quantitative" and **c** to stand for "categorical" instead of the reverse way. The reason is simple: "quantitative" gives 112 million google results while "qualitative" only gives me 67 million. (I hope there could be better ways to make these two terms more distinctive but "continuous" vs "categorical"? No way...)

The major functions in `ezsummary` include

-   **`ezsummary`** & var\_types
-   `ezsummary_categorical`
-   `ezsummary_quantitative`
-   **`ezmarkup`**

Both `ezsummary_categorical` and `ezsummar_quantitative` can be used independently. By default, `ezsummary_categorical` will give you the count and proportion of each category. If you want to know total counts, you will need to set the option `n = T`. If you want to display Percentage instead of proportion, you will need to disable proportion by `p = F` and enable Percentage by `P = T`. Similarly, `ezsummary_quantitative` works in the same way but it has more options, including standard error of the mean(SEM) `sem`, `median` and `quantile`. You can adjust the rounding by using `round.N`. Here are two examples using our beloved `mtcars`.

``` r
library(ezsummary)
library(knitr)

kable(
  mtcars %>%
  select(am, cyl) %>%
  ezsummary_categorical(n=T)
  )
```

| variable |    N|  count|      p|
|:---------|----:|------:|------:|
| am\_0    |   32|     19|  0.594|
| am\_1    |   32|     13|  0.406|
| cyl\_4   |   32|     11|  0.344|
| cyl\_6   |   32|      7|  0.219|
| cyl\_8   |   32|     14|  0.438|

``` r

kable(
  mtcars %>%
  group_by(am) %>%
  select(mpg, wt, hp) %>%
  ezsummary_quantitative(sd = F, sem = T, round.N = 1)
  )
```

|   am| variable |   mean|   sem|
|----:|:---------|------:|-----:|
|    0| mpg      |   17.1|   0.9|
|    1| mpg      |   24.4|   1.7|
|    0| wt       |    3.8|   0.2|
|    1| wt       |    2.4|   0.2|
|    0| hp       |  160.3|  12.4|
|    1| hp       |  126.8|  23.3|

If you are doing analyses by group, like the example above, by the default setting of `ezsummary`, you will get a "tidy" formated table of results, in which the grouping information are listed as column(s) on the left. This format allows you to keep process your results. If you want the grouping information to be organized into row.names and makes the table wider, which is more "publish ready", you should use the `flavor` option. There are two options available, "long" and "wide".

``` r
kable(
  mtcars %>%
  group_by(am) %>%
  select(mpg, wt, hp) %>%
  ezsummary_quantitative(sd = F, sem = T, round.N = 1, flavor = "wide")
  )
```

| variable |  am.0\_mean|  am.0\_sem|  am.1\_mean|  am.1\_sem|
|:---------|-----------:|----------:|-----------:|----------:|
| mpg      |        17.1|        0.9|        24.4|        1.7|
| wt       |         3.8|        0.2|         2.4|        0.2|
| hp       |       160.3|       12.4|       126.8|       23.3|

(You may have notived that I'm using dot to separate grouping variable name and option and using underscore to separate grouping info and stats names. As as result, it will be a little easier for people who are not that familar with `regex` to cut the names and reshape the results.)

Now you feel like it is not that easy to read mean and sem on the same row. Well, we have `ezmarkup`. In this function, we use a dot `.` to represent a column and use a pair of bracket `[]` to represent you want to **"squeeze"** the columns inside into one. Any other symbols and characters within a pair of bracket will be copied into the same cell as well. It allows us to do advanced formatting settings in a very convenient way. Here are two examples.

``` r
kable(
  mtcars %>%
  group_by(am) %>%
  select(mpg, wt, hp) %>%
  ezsummary_quantitative(sd = F, sem = T, round.N = 1, flavor = "wide") %>%
  ezmarkup(".[. (.)][. (.)]")
  )
```

| variable | am.0\_mean (am.0\_sem) | am.1\_mean (am.1\_sem) |
|:---------|:-----------------------|:-----------------------|
| mpg      | 17.1 (0.9)             | 24.4 (1.7)             |
| wt       | 3.8 (0.2)              | 2.4 (0.2)              |
| hp       | 160.3 (12.4)           | 126.8 (23.3)           |

``` r

kable(
  mtcars %>%
  group_by(am) %>%
  select(mpg, wt, hp) %>%
  ezsummary_quantitative(sd = F, sem = T, round.N = 1, flavor = "wide") %>%
  ezmarkup(".[. <sub>.</sub>][. <sub>.</sub>]"),
  
  escape = F
  )
```

| variable | am.0\_mean <sub>am.0\_sem</sub> | am.1\_mean <sub>am.1\_sem</sub> |
|:---------|:--------------------------------|:--------------------------------|
| mpg      | 17.1 <sub>0.9</sub>             | 24.4 <sub>1.7</sub>             |
| wt       | 3.8 <sub>0.2</sub>              | 2.4 <sub>0.2</sub>              |
| hp       | 160.3 <sub>12.4</sub>           | 126.8 <sub>23.3</sub>           |

``` r
demo <- mtcars %>% 
  group_by(am) %>%  
    select(mpg, cyl, disp) %>%
      var_types("cqcq") # tell ezsummary to treat cyl as a categorical variable

results <- demo %>% ezsummary()
kable(results)
```

|   am| variable | mean\_n |    sd\_p|
|----:|:---------|:--------|--------:|
|    0| mpg      | 17.147  |    3.834|
|    1| mpg      | 24.392  |    6.167|
|    0| cyl\_4   | 3       |    0.158|
|    1| cyl\_4   | 8       |    0.615|
|    0| cyl\_6   | 4       |    0.211|
|    1| cyl\_6   | 3       |    0.231|
|    0| cyl\_8   | 12      |    0.632|
|    1| cyl\_8   | 2       |    0.154|
|    0| disp     | 290.379 |  110.172|
|    1| disp     | 143.531 |   87.204|

``` r
library(ezsummary)

demo <- mtcars %>% 
  group_by(am) %>%  
    select(mpg, cyl, disp) %>%
      var_types("cqcq") # tell ezsummary to treat cyl as a categorical variable

results <- demo %>% ezsummary()
kable(results)
```

|   am| variable | mean\_n |    sd\_p|
|----:|:---------|:--------|--------:|
|    0| mpg      | 17.147  |    3.834|
|    1| mpg      | 24.392  |    6.167|
|    0| cyl\_4   | 3       |    0.158|
|    1| cyl\_4   | 8       |    0.615|
|    0| cyl\_6   | 4       |    0.211|
|    1| cyl\_6   | 3       |    0.231|
|    0| cyl\_8   | 12      |    0.632|
|    1| cyl\_8   | 2       |    0.154|
|    0| disp     | 290.379 |  110.172|
|    1| disp     | 143.531 |   87.204|

You can configue the options to make the output more "print ready". Feature Options include:

-   flavor: "long" or "wide"

    -   The "long" format is more tidy and is more machine readable. In this format, grouping variable(s) and the variable-name variable are the ID variables and organized in the first several columns of the table. It is the default export flavor for ezsummary and it sub-functions.

    -   The "wide" format is more "print ready" version of the output. In this format, the only ID variable is the variable-name variable and all of the grouping info will be put into the column names.

-   unit\_markup: If you want to organize each sets of mean and stand deviation into a format like "mean (sd)", you can set the value of this option as "\[. (.)\]". Here, each dot represents a column and the bracket means that you want to squeeze those two columns inside the bracket into one. You can even do "\[.<sup>.</sup>\]" to turn the second element as the superscription of the first element.

``` r
results_formatted <- demo %>% ezsummary(flavor = "wide", unit_markup = "[. (.)]")
kable(results_formatted)
```

| variable | am.0\_mean\_n (sd\_p) | am.1\_mean\_n (sd\_p) |
|:---------|:----------------------|:----------------------|
| mpg      | 17.147 (3.834)        | 24.392 (6.167)        |
| cyl\_4   | 3 (0.158)             | 8 (0.615)             |
| cyl\_6   | 4 (0.211)             | 3 (0.231)             |
| cyl\_8   | 12 (0.632)            | 2 (0.154)             |
| disp     | 290.379 (110.172)     | 143.531 (87.204)      |

Issues
------

If you ever find any issues, please feel free to report it in the issues tracking part on github. [<https://github.com/haozhu233/simple.summary/issues>](https://github.com/haozhu233/simple.summary/issues).

Thanks for using this package!
