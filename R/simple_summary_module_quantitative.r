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
#' @param round.N Rounding Number
#'
#' @return It will return in the same format as a summarise_each function does
#'
#' @examples
#' mtcars %>% group_by(am) %>% select(mpg, wt, qsec) %>% simple_summary_quantitative()
#'
#' @export
simple_summary_quantitative <- function(tbl, n=F, round.N=3){
  n.group <- length(attributes(tbl)$vars)
  n.var <- length(attributes(tbl)$names) - length(attributes(tbl)$vars)
  table_export <- data.frame(x = rep(names(tbl)[(n.group + 1):(n.group + n.var)], rep((n.group + 1), n.var)))
  # generate table_raw from summarise_each based on switches; Apply round.N
  if (n == F) {table_raw <- summarise_each(tbl, funs(mean = round(mean(na.omit(.)), round.N), sd = round(sd(na.omit(.)), round.N)))
  }else{
    table_raw <- summarise_each(tbl, funs(N = length(na.omit(.)), mean = round(mean(na.omit(.)), round.N), sd = round(sd(na.omit(.)), round.N)))
    for(i in 1:(n.var * (nrow(table_raw)))){table_export$N[i] = table_raw[(i - nrow(table_raw) * (ceiling(i/nrow(table_raw))-1)),(n.group + ceiling(i/nrow(table_raw)))]}
    }
  # Fix the default naming when n.var == 1
  # if (n.var == 1) {names(table_raw)[(n.group + 1):ncol(table_raw)] <- paste(names(tbl)[(n.group + 1)], names(table_raw)[(n.group + 1):ncol(table_raw)], sep = "_")}
  for(i in 1:(n.var * (nrow(table_raw)))){table_export$mean[i] = table_raw[(i - nrow(table_raw) * (ceiling(i/nrow(table_raw))-1)), (n.group + ceiling(i/nrow(table_raw)) + n.var * n)]}
  for(i in 1:(n.var * (nrow(table_raw)))){table_export$sd[i] = table_raw[(i - nrow(table_raw) * (ceiling(i/nrow(table_raw))-1)), (n.group + ceiling(i/nrow(table_raw)) + n.var * n + n.var)]}

  if(n.group != 0) {table_export <- cbind(table_raw[rep(1:nrow(table_raw), times = n.var),1:n.group], table_export)}
  attributes(table_export)$n.group <- n.group
  attributes(table_export)$n.var <- n.var
  return(table_export)
}
