#' Simple Summary for Quantitative/binary variables
#'
#' @description Function simple_summary_quantitative provides simple summary (Mean and
#' standard deviation with/without N) for quantitative data while function simple_summary_binary
#' provides simple summary (freq and percentage with/without total counts) for binary data.
#' These two function are simply wrappers outside of a summarise_each function. If
#' we just want to know the most basic statistical summary, this function can save us some
#' typing time. It also provide the option to include number of subjects inside the analyses.
#'
#' @param tbl The input matrix of data you would like to analyze.
#' @param n n is a True/False switch that controls whether counts(N) should be included in
#' the output
#'
#' @return It will return in the same format as a summarise_each function does
#'
#' @examples
#' mtcars %>% group_by(am) %>% select(mpg, wt, qsec) %>% simple_summary_quantitative()
#'
#' @export
simple_summary_quantitative <- function(tbl, n=F){
  if (n ==T ) {
    summarise_each(tbl, funs(
      N = length(na.omit(.)),
      Mean = mean(na.omit(.)),
      SD = sd(na.omit(.))))

  } else {
    summarise_each(tbl, funs(
      Mean = mean(na.omit(.)),
      SD = sd(na.omit(.))))
  }
}



#' @rdname simple_summary_quantitative
#' @export
simple_summary_binary <- function(tbl, n=F){
  if (n ==T ) {
    summarise_each(tbl, funs(
      N = length(na.omit(.)),
      n = sum(na.omit(. == 1)),
      percentage = mean(., na.rm=T)*100))
  } else {
    summarise_each(tbl, funs(
      n = sum(na.omit(. == 1)),
      percentage = mean(., na.rm=T)*100))
  }
}
