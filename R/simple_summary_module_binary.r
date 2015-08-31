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
