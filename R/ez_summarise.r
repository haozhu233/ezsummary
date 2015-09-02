#' Quick and Easy summarise function
#'
#' @param tbl The input matrix of data you would like to analyze.
#' @param n n is a True/False switch that controls whether counts(N) should be included in
#' the output
#' @param round.N Rounding Number
#'
#' @export
ez_summarise <- function(tbl, n=F, round.N=3){
  if(is.vector(tbl)){
    tbl <- as.tbl(as.data.frame(tbl))
    attributes(tbl)$names <- "x"
    warning("ezsummary cannot detect the naming information from the atomic vector you entered. Please try to use something like select(mtcars, gear) instead of using mtcars$gear directly.")
  }
  tbl <- auto_var_types(tbl)
  tbl.q <- tbl[, attributes(tbl)$var_types == "q" | attributes(tbl)$var_types == "g"]
  tbl.c <- tbl[, attributes(tbl)$var_types == "c" | attributes(tbl)$var_types == "g"]
  tbl.q.result <- NULL
  tbl.c.result <- NULL
  if (length(tbl.q) > length(attributes(tbl)$vars)){
    tbl.q.result <- ez_summarise_quantitative(tbl = tbl.q, n=n, round.N = round.N)}
  if (length(tbl.c) > length(attributes(tbl)$vars)){
    tbl.c.result <- ez_summarise_categorical(tbl = tbl.c, n=n, round.N = round.N)}
  if (!is.null(tbl.q.result) & !is.null(tbl.c.result)){
    tbl.q.result <- rename(tbl.q.result, mean_freq = mean)
    tbl.c.result <- rename(tbl.c.result, mean_freq = freq)
    tbl.q.result <- rename(tbl.q.result, sd_p = sd)
    tbl.c.result <- rename(tbl.c.result, sd_p = percentage)
  }
  tbl.result <- rbind.fill(tbl.q.result, tbl.c.result)
  return(tbl.result)
}




