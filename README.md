# ezsummary 
Travis CI: [![Build Status](https://travis-ci.org/haozhu233/ezsummary.svg?branch=master)](https://travis-ci.org/haozhu233/ezsummary)  Test Coverage: [![Coverage Status](https://coveralls.io/repos/haozhu233/ezsummary/badge.svg?branch=master&service=github)](https://coveralls.io/github/haozhu233/ezsummary?branch=master)


## Introduction
Hadley's `dplyr` is very powerful and the "ecosystem" around it, such as `reshape2` and `tidyr`, makes it even better. However, sometimes when I want to do some very simple and common tasks (like getting average, sd..), I still need to spend some extra time on coding and fixing the format of the output before the results is "visually" ready to be printed in a `rmarkdown` report or on a `shiny` page. This package is built for saving us a little bit more time when we are doing "descriptive summary" jobs, which, unfortunately, takes up to 40-70% of our jobs for some of us. 

Also, I'm trying to make it newbie friendly (despite the nerd-friendly installation part). :)

## To install
Type  
``` r
    install.packages("devtools")
    devtools::install_github("haozhu233/ezsummary")
```
  
## To use

The ultimate goal of this package is to keep everything simple and handy. Here is an example of using this package and `dplyr` to analyze variable `mpg`, `cly` and `disp` in dataset `mtcars` grouped by `am`. Note that `mpg` and `disp` are quantitative variables while `cly` is a qualitative (categorical) variable. 
``` r
library(ezsummary)
results <- mtcars %>% 
  group_by(am) %>%  
    select(mpg, cyl, disp) %>%
      var_types("cqcq") %>% # tell ezsummary to treat cyl as a categorical variable
      ezsummary(flavor = "wide", unit_markup = "[. (.)]")
results
```
See the output:
``` r
  variable am.0_mean_n (sd_p) am.1_mean_n (sd_p)
1      mpg     17.147 (3.834)     24.392 (6.167)
2    cyl_4          3 (0.158)          8 (0.615)
3    cyl_6          4 (0.211)          3 (0.231)
4    cyl_8         12 (0.632)          2 (0.154)
5     disp  290.379 (110.172)   143.531 (87.204)
```
You can even reformat the output by using the `ezmarkup` function where each dot represent a column and columns inside a pair of bracket will be combined in the format provided. 
``` r
results %>% ezmarkup("..[. (.)]")
```
Output
``` r
   am variable     mean_n (sd_p)
1   0      mpg    17.147 (3.834)
2   1      mpg    24.392 (6.167)
3   0    cyl_4         3 (0.158)
4   0    cyl_6         4 (0.211)
5   0    cyl_8        12 (0.632)
6   1    cyl_4         8 (0.615)
7   1    cyl_6         3 (0.231)
8   1    cyl_8         2 (0.154)
9   0     disp 290.379 (110.172)
10  1     disp  143.531 (87.204)
```


## Issues
If you ever find any issues, please feel free to report it in the issues tracking part on github. [https://github.com/haozhu233/simple.summary/issues](https://github.com/haozhu233/simple.summary/issues). 

Thanks for using this package!
