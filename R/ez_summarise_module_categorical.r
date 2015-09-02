#' Easy summary for categorical data
#'
#' @description This function provided an easy-to-use way to display simple statistical
#' summary for categorical data. It can be used together with \code{\link[dplyr]{select}}
#' and \code{\link[dplyr]{group_by}}. If the piece of data passed into the function has
#' one/multiple group_by variables, the percentage and count will be calculated within
#' the defined groups.
#'
#' @param tbl The input matrix of data you would like to analyze.
#' @param n n is a True/False switch that controls whether total counts(N) should be included in
#' the output.
#' @param round.N Rounding number.
#'
#' @return This function will organize all the results into one dataframe. If there are
#' any group_by variables, the first few columns will be them. After these, the varible
#' x will be the one listing all the categorical options in a format like "variable_option".
#' The stats summaries are listed in the last few columns.
#'
#' @examples
#' mtcars %>% group_by(am) %>% select(cyl, gear, carb) %>% ez_summarise_categorical()
#' mtcars %>% select(cyl, gear, carb) %>% ez_summarise_categorical(n=TRUE, round.N = 2)
#'
#' @export
ez_summarise_categorical <- function(tbl, n=F, round.N=3){
  if(is.vector(tbl)){
    tbl <- as.tbl(as.data.frame(tbl))
    attributes(tbl)$names <- "x"
    warning("ezsummary cannot detect the naming information from the atomic vector you entered. Please try to use something like select(mtcars, gear) instead of using mtcars$gear directly.")
  }
  n.group <- length(attributes(tbl)$vars)
  n.var <- length(attributes(tbl)$names) - length(attributes(tbl)$vars)
  table_raw <- NULL
  if (n.group == 0){
    if(n == T){for (i in 1:n.var){table_raw[[i]]<-count_percentage(tbl[,i], n=T, round.N=round.N)}
    }else{for (i in 1:n.var){table_raw[[i]]<-count_percentage(tbl[,i], round.N=round.N)}
    }
    names(table_raw) <- names(tbl)
    name_fix <- rep(names(table_raw), data.frame(lapply(table_raw, nrow))[1,])
    table_export <- rbind_all(table_raw)
    table_export$x <- paste(name_fix, table_export$x, sep="_")
  } else {
    tbl_order <- 1:(n.group + n.var)
    tbl_order <- c(which(suppressWarnings(attributes(tbl)$vars == names(tbl))), tbl_order[!tbl_order %in% which(suppressWarnings(attributes(tbl)$vars == names(tbl)))])
    tbl <- tbl[,tbl_order]
    if(n == T){for (i in 1:n.var){table_raw[[i]]<-count_percentage_(tbl[,c(1:n.group, i + n.group)], n=T, round.N=round.N)}
    }else{for (i in 1:n.var){table_raw[[i]]<-count_percentage_(tbl[,c(1:n.group, i + n.group)], round.N=round.N)}
    }
    names(table_raw) <- names(tbl)[(n.group + 1):(n.group + n.var)]
    name_fix <- rep(names(table_raw), data.frame(lapply(table_raw, nrow))[1,])
    # fix the naming in the list of data frames
    name_fix_function <- function(df, var_position){names(df)[var_position] <- "x"
    return(df)}
    table_raw <- lapply(table_raw, name_fix_function, n.group + 1)
    table_export <- rbind_all(table_raw)
    table_export$x <- paste(name_fix, table_export$x, sep="_")
  }
  attributes(table_export)$n.group <- n.group
  attributes(table_export)$n.var <- n.var
  return(table_export)
}

#' Counts and Percentages
#'
#' @description This is a calculating module used by \code{\link{ez_summarise_categorical}} but
#' it can also be used independently.
#'
#' @param data_vector Vector that is passed into the function to do the calculation.
#' Function count_percentage can only work with vectors.
#' @param data_matrix Matrix or data.frame that is passed into the function.
#' Function count_percentage_ can proceed 2 dimensional data.
#' @param n n is a True/False switch that controls whether total counts(N) should be included in
#' the output.
#' @param round.N Rounding number.
#'
#'
#' @export
count_percentage <- function(data_vector, n=F, round.N=3){
  table_export <- plyr::count(na.omit(data_vector))
  table_export$percentage <- prop.table(table_export$freq)
  if (n==T) {table_export <- cbind(table_export, N = as.integer(round(table_export$freq / table_export$percentage,0)))
  table_export <- table_export[, c(1:(ncol(table_export)-3), ncol(table_export), ncol(table_export)-2, ncol(table_export)-1)]
  }
  table_export$percentage <- round(table_export$percentage,round.N)
  return(table_export)
}

#' @rdname count_percentage
#' @export
count_percentage_ <- function(data_matrix, n=F, round.N=3){do(data_matrix, count_percentage(., n=n, round.N=round.N))}




