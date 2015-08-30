#' Simple summary for categorical data
#'
#' @description This function provided an easy-to-use way to display simple statistical
#' summary for categorical data. It can be used together with \code{\link{dplyr::select}}
#' and \code{\link{dplyr::group_by}}. If the piece of data passed into the function has
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
#' mtcars %>% group_by(am) %>% select(cyl, gear, carb) %>% simple_summary_categorical()
#' mtcars %>% select(cyl, gear, carb) %>% simple_summary_categorical(n=T, round.N = 2)
#'
#' @export
simple_summary_categorical <- function(tbl, n=F, round.N=3){
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
#' @description This is a calculating module used by \code{\link{simple_summary_categorical}} but
#' it can also be used independently.
#'
#' @export
count_percentage <- function(data_vector, n=F, round.N=3){
  table_export <- plyr::count(na.omit(data_vector))
  table_export$Percentage <- prop.table(table_export$freq)
  if (n==T) {table_export <- cbind(table_export, N = as.integer(round(table_export$freq / table_export$Percentage,0)))
  table_export <- table_export[, c(1:(ncol(table_export)-3), ncol(table_export), ncol(table_export)-2, ncol(table_export)-1)]
  }
  table_export$Percentage <- round(table_export$Percentage,round.N)
  return(table_export)
}

#' @rdname count_percentage
#' @export
count_percentage_ <- function(a, n=F, round.N=3){do(a, count_percentage(., n=n, round.N=round.N))}




