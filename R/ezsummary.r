#' Quick and Easy summarise function
#'
#' @param tbl A vector, a data.frame or a \code{dplyr} \code{tbl}.
#' @param ... Arguments that can be passed to \code{ezsummary_q()} and
#' \code{ezsummary_c()}
#'
#' @import dplyr
#' @importFrom tidyr separate
#' @importFrom stats as.formula sd
#'
#' @export

ezsummary <- function(tbl, ...){

  # Define the following variable to avoid NOTE on RMD check
  variable = variable_backup = variable1 = variable2 = p = NULL

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
  # # Fix the naming
  # if (!is.null(tbl_q_result) & !is.null(tbl_c_result)){
  #   tbl_q_result <- rename(tbl_q_result, mean_n = mean)
  #   tbl_c_result <- rename(tbl_c_result, mean_n = count)
  #   tbl_q_result <- rename(tbl_q_result, sd_p = sd)
  #   tbl_c_result <- rename(tbl_c_result, sd_p = p)
  #   # assign mean_n as factor
  #   tbl_q_result$mean_n <- factor(tbl_q_result$mean_n)
  #   tbl_c_result$mean_n <- factor(tbl_c_result$mean_n)
  # }
  # # Combine the results
  # tbl_result <- suppressWarnings(rbind_all(list(tbl_q_result, tbl_c_result)))
  #
  # # Ezmarkup
  # if(!is.null(unit_markup)){
  #   ezmarkup_formula <- paste0(paste0(rep(".", n.group), collapse = ""), ".", unit_markup, "..")
  #   tbl_result <- ezmarkup(tbl_result, ezmarkup_formula)
  # }
  #
  # # Turn the table from long to wide if needed
  # if(flavor == "wide"){
  #   for(i in 1:n.group){
  #     tbl_result[,group.name[i]] <- paste(group.name[i], unlist(tbl_result[,group.name[i]]), sep=".")
  #   }
  #   tbl_result <- suppressWarnings(tbl_result %>% melt(id.var = c(group.name, "variable1", "variable2", "variable"), variable.name = "stats.var"))
  #   dcast_formula <- paste0("dcast(tbl_result, variable1 + variable2 +variable ~ ", paste0(c(group.name, "stats.var"), collapse = " + "), ")")
  #   tbl_result <- eval(parse(text = dcast_formula))
  # }
  #
  # # Sort the variables in the order the variables were provided
  # # factorize variable1
  # tbl_result$variable1 <- factor(tbl_result$variable1, levels = var.name)
  # tbl_result <- tbl_result %>% arrange(variable1, variable2) %>% select(-variable1, -variable2)

  return(list(tbl_q_result, tbl_c_result))
}
