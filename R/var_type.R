#' Attach the variable type information with the dataset
#'
#' @description In order to analyze variables in the most appropriate way using this
#' \code{ezsummary} package, you'd better let the computer know what types of data
#' (quantitative or categorical) you are asking it to compute. This function will
#' attach a list of types you entered with the datasets so functions down the stream
#' line can read these information and analyze based on that. The information is stored
#' in the attributes of the dataset
#'
#' @param tbl A data.frame
#' @param types Character vector of length equal to the number of variables (excluding
#' grouping variables)in the dataset. Use "q" and "c" to denote quantitative and
#' categorical variables.
#'
#' @export

var_type <- function(tbl, types){
  if(!is.data.frame(tbl))stop("Please supply a data.frame/data.table as the value of tbl")
  if(nchar(types) != length(attributes(tbl)$names) - length(attributes(tbl)$vars))stop("The length of the string you entered doesn't match the number of variables (excluding grouping variables)")
  if(grepl("[^cq]", types)) stop('Unrecognizable character(s) detected!! Please review your input and use "q" and "c" to denote quantitative and categorical variables. ')
  attributes(tbl)$var_types <- unlist(strsplit(types, ""))
  return(tbl)
}

#' @rdname var_type
#' @export

var_types_are <- function(tbl, types){
  return(var_type(tbl,types))
}

#' @rdname var_type
#' @export

enchant <- function(tbl, types){
  return(var_type(tbl,types))
}
