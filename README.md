<!-- README.md is generated from README.Rmd. Please edit that file -->
ezsummary
=========

Travis CI: [![Build Status](https://travis-ci.org/haozhu233/ezsummary.svg?branch=master)](https://travis-ci.org/haozhu233/ezsummary) Test Coverage: [![Coverage Status](https://coveralls.io/repos/haozhu233/ezsummary/badge.svg?branch=master&service=github)](https://coveralls.io/github/haozhu233/ezsummary?branch=master)

Introduction
------------

Hadley's `dplyr` is very powerful and the "ecosystem" around it, such as `reshape2` and `tidyr`, makes it even better. However, sometimes when I want to do some very simple and common tasks (like getting average, sd..), I still need to spend some extra time on coding and fixing the format of the output before the results is "visually" ready to be printed in a `rmarkdown` report or on a `shiny` page. This package is built for saving us a little bit more time when we are doing "descriptive summary" jobs, which, unfortunately, takes up to 40-70% of our jobs for some of us.

Also, I'm trying to make it newbie friendly (despite the nerd-friendly installation part). :)

To install
----------

Type

``` r
    install.packages("devtools")
    devtools::install_github("haozhu233/ezsummary")
```

To use
------

The ultimate goal of this package is to keep everything simple and handy. Here is an example of using this package and `dplyr` to analyze variable `mpg`, `cly` and `disp` in dataset `mtcars` grouped by `am`. Note that `mpg` and `disp` are quantitative variables while `cly` is a qualitative (categorical) variable.

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

-   unit\_markup: If you want to organize each sets of mean and stand deviation into a format like "mean (sd)", you can set the value of this option as "[. (.)]". Here, each dot represents a column and the bracket means that you want to squeeze those two columns inside the bracket into one. You can even do "[.<sup>.</sup>]" to turn the second element as the superscription of the first element.

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
