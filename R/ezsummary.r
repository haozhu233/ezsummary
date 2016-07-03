#' Quick and Easy summarise function
#'
#' @param tbl A vector, a data.frame or a \code{dplyr} \code{tbl}.
#' @param ... Arguments that can be passed to \code{ezsummary_q()} and
#' \code{ezsummary_c()}
#' @param mode A character value that can be either \code{"ez"} or
#' \code{"details"}. \code{"ez"} is the default mode that will try to fits
#' quantitative and categorical results into one table. If these two have
#' different number of analyses or if set manually, mode \code{"details"} is
#' enabled. In this mode, quantitative and categorical variables are displayed
#' separately and the result is stored in a list
#'
#' @details For detailed options, please check the help document for
#' \code{\link{ezsummary_q}} and \code{\link{ezsummary_c}}. You may also check
#' out the package vignette for details.
#'
#' @import dplyr
#' @import tidyr
#' @importFrom stats as.formula sd
#'
#' @export

ezsummary <- function(tbl, ..., mode = c("ez", "details")){

  # Define the following variable to avoid NOTE on RMD check
  reorder_list <- NULL

  mode <- match.arg(mode)

  ez_options <- list(...)

  ez_options_q <- ez_options[names(ez_options) %in% c(
    "total", "n", "missing", "mean", "sd", "sem", "median",
    "quantile", "extra", "digits", "rounding_type", "round.N",
    "flavor", "fill", "unit_markup"
  )]
  ez_options_c <- ez_options[names(ez_options) %in% c(
    "n", "count", "p", "p_type", "digits", "rounding_type",
    "P", "round.N", "flavor", "fill", "unit_markup"
  )]

  if(is.vector(tbl)){
    tbl <- as.tbl(as.data.frame(tbl))
    attributes(tbl)$names <- "unknown"
    warning('ezsummary cannot detect the naming information from an atomic ',
            'vector. If you want to have full naming information, please ',
            'pass the value in as a data frame using `select` from dplyr.')
  }

  group_name <- attributes(tbl)$vars
  var_name <- attributes(tbl)$names
  if (!is.null(group_name)){
    group_name <- as.character(group_name)
    var_name <- var_name[!var_name %in% group_name]
  }
  n_group <- length(group_name)
  n_var <- length(var_name)

  # auto assign var.types if not assigned
  tbl <- auto_var_types(tbl)

  tbl_q <- tbl %>%
    select(seq(1, ncol(tbl))[attr(tbl, "var_types") %in% c("q", "g")])
  tbl_c <- tbl %>%
    select(seq(1, ncol(tbl))[attr(tbl, "var_types") %in% c("c", "g")])

  tbl_q_result <- NULL
  tbl_c_result <- NULL
  if (length(tbl_q) > n_group){
    tbl_q_result <- do.call("ezsummary_q",
                            append(list(tbl = tbl_q), ez_options_q))
    }
  if (length(tbl_c) > n_group){
    tbl_c_result <- do.call("ezsummary_c",
                            append(list(tbl = tbl_c), ez_options_c))
  }

  if(is.null(tbl_c_result))return(tbl_q_result)
  if(is.null(tbl_q_result))return(tbl_c_result)

  if(ncol(tbl_q_result) != ncol(tbl_c_result)){
    warning('You have to make sure quantitative and categorical variables ',
            'share the same number of analyses in order to use the "ez" mode.',
            ' Now the "details" mode is being used. Please read the ',
            'documentation for ezsummary() for details. ')
    mode <- "details"
  }

  if(mode == "ez"){
    if(attr(tbl_q_result, "flavor") == "long"){
      q_col_names <- names(tbl_q_result)[(2+n_group):ncol(tbl_q_result)]
      c_col_names <- names(tbl_c_result)[(2+n_group):ncol(tbl_c_result)]
      new_names <- matrix(c(q_col_names, c_col_names), ncol = 2) %>%
        apply(1, function(x){
          if(x[1] == x[2]){return(x[1])}else{
            paste0(x[1], "/", x[2])
          }
        })
      names(tbl_q_result)[(2+n_group):ncol(tbl_q_result)] <- new_names
      names(tbl_c_result)[(2+n_group):ncol(tbl_c_result)] <- new_names
    }else{
      q_col_names <- names(tbl_q_result)[2:ncol(tbl_q_result)]
      c_col_names <- names(tbl_c_result)[2:ncol(tbl_c_result)]
      new_names <- matrix(c(q_col_names, c_col_names), ncol = 2) %>%
        apply(1, function(x){
          if(x[1] == x[2]){return(x[1])}else{
            paste0(x[1], "/",
                   unlist(regmatches(x[2], regexec("[^_]*$", x[2]))))
          }
        })
      names(tbl_q_result)[2:ncol(tbl_q_result)] <- new_names
      names(tbl_c_result)[2:ncol(tbl_c_result)] <- new_names
    }
    tbl_q_result[1:ncol(tbl_q_result)] <- sapply(
      tbl_q_result[1:ncol(tbl_q_result)], as.factor)
    tbl_c_result[1:ncol(tbl_c_result)] <- sapply(
      tbl_c_result[1:ncol(tbl_c_result)], as.factor)
    tbl_q_result$reorder_list <- tbl_q_result$variable
    tbl_c_result$reorder_list <- attr(tbl_c_result, "categories")
    tbl_result <- bind_rows(tbl_q_result, tbl_c_result) %>%
      mutate(reorder_list = factor(reorder_list, levels = var_name)) %>%
      arrange(reorder_list) %>%
      select(-reorder_list)
    return(tbl_result)
  }

  if(mode == "details"){
    return(list(Quantitative = tbl_q_result, Categorical = tbl_c_result))
  }
}
