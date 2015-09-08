#' Quick and Easy summarise function
#'
#' @param tbl The input matrix of data you would like to analyze.
#' @param n n is a True/False switch that controls whether counts(N) should be included in
#' the output
#' @param round.N Rounding Number
#'
#' @export
ez_summarise <- function(tbl, n=F, round.N=3){
  # If the input tbl is a vector, convert it to a 1-D data.frame and set it as a 'tbl' (dplyr).
  if(is.vector(tbl)){
    tbl <- as.tbl(as.data.frame(tbl))
    attributes(tbl)$names <- "unknown"
    warning("ezsummary cannot detect the naming information from an atomic vector. Please try to use something like 'select(mtcars, gear)' to replace mtcars$gear in your code.")
  }

  # Try to obtain grouping and variable information from the input tbl
  group.name <- attributes(tbl)$vars
  var.name <- attributes(tbl)$names
  if (!is.null(group.name)){
    group.name <- as.character(group.name)
    var.name <- var.name[!var.name %in% group.name]
  }
  n.group <- length(group.name)
  n.var <- length(var.name)

  tbl <- auto_var_types(tbl)
  tbl.q <- tbl[, attributes(tbl)$var_types == "q" | attributes(tbl)$var_types == "g"]
  tbl.c <- tbl[, attributes(tbl)$var_types == "c" | attributes(tbl)$var_types == "g"]
  tbl.q.result <- NULL
  tbl.c.result <- NULL
  if (length(tbl.q) > n.group){
    tbl.q.result <- ez_summarise_quantitative(tbl = tbl.q, n=n, round.N = round.N)}
  if (length(tbl.c) > n.group){
    tbl.c.result <- ez_summarise_categorical(tbl = tbl.c, n=n, round.N = round.N)}
  if (!is.null(tbl.q.result) & !is.null(tbl.c.result)){
    tbl.q.result <- rename(tbl.q.result, mean_n = mean)
    tbl.c.result <- rename(tbl.c.result, mean_n = count)
    tbl.q.result <- rename(tbl.q.result, sd_p = sd)
    tbl.c.result <- rename(tbl.c.result, sd_p = p)
  }
  tbl.result <- rbind(tbl.q.result, tbl.c.result)
  #tbl.result[sapply(tbl.result, class) == "list"] <- unlist(tbl.result[sapply(tbl.result, class) == "list"])
  return(tbl.result)
}




