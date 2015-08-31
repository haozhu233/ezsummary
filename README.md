# simple.summary 
Travis CI: [![Build Status](https://travis-ci.org/haozhu233/simple.summary.svg?branch=master)](https://travis-ci.org/haozhu233/simple.summary)  Test Coverage: [![Coverage Status](https://coveralls.io/repos/haozhu233/ezsummary/badge.svg?branch=master&service=github)](https://coveralls.io/github/haozhu233/ezsummary?branch=master)

Both `dplyr` and `data.table` have made the our data analytical job a lot easier. However, I still find that sometimes I need to type the same codes again and again to do some very simple jobs in my everyday life. For example, I found that I need to code a lot to fix the formatting to put those result into a table and get displayed through `rmarkdown` or `shiny`. This package is built to save us, at least people who are working with small-medium size data, a little bit more typing time.

## To install

Type  
``` r
    if (packageVersion("devtools") < 1.6) {
      install.packages("devtools")
    }
    devtools::install_github("haozhu233/simple.summary")
```
  
## To use

You are recommended to use `dplyr` together with this package. I haven't tested `data.table` but it should work at a minimum base as well. 

A simple exmaple is provided here. 
``` r
library(dplyr)
library(simple.summary)
  mtcars %>% 
    group_by(am) %>% 
      select(cyl, gear) %>% 
        simple_summary_categorical()
```
And the output will look like the following table. For those who are not familar with the `dplyr`(`pipe`) syntax, this piece of script will do categorical analyses to variable `cyl` and `gear` in the `mtcars` dataset grouped by variable `am`. 
``` r
Source: local data frame [10 x 4]

   am      x freq Percentage
1   0  cyl_4    3      0.158
2   0  cyl_6    4      0.211
3   0  cyl_8   12      0.632
4   1  cyl_4    8      0.615
5   1  cyl_6    3      0.231
6   1  cyl_8    2      0.154
7   0 gear_3   15      0.789
8   0 gear_4    4      0.211
9   1 gear_4    8      0.615
10  1 gear_5    5      0.385
```

## Issues
If you ever find any issues, please feel free to report it in the issues tracking part on github. [https://github.com/haozhu233/simple.summary/issues](https://github.com/haozhu233/simple.summary/issues). 

Thanks for using this package!
