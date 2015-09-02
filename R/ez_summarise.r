ez_summarise <- function(tbl, n=F, round.N=3){
  if(is.vector(tbl)){
    tbl <- as.tbl(as.data.frame(tbl))
    attributes(tbl)$names <- "x"
    warning("ezsummary cannot detect the naming information from the atomic vector you entered. Please try to use something like select(mtcars, gear) instead of using mtcars$gear directly.")
  }
  tbl <- auto_var_type(tbl)
  dplyr::select_vars()
}




