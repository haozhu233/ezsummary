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

  # auto assign var.types if not assigned
  tbl <- auto_var_types(tbl)
  # split dataset and do the analyses separately
  tbl_q <- tbl[, attributes(tbl)$var_types == "q" | attributes(tbl)$var_types == "g"]
  tbl_c <- tbl[, attributes(tbl)$var_types == "c" | attributes(tbl)$var_types == "g"]
  tbl_q_result <- NULL
  tbl_c_result <- NULL
  if (length(tbl_q) > n.group){
    tbl_q_result <- ez_summarise_quantitative(tbl = tbl_q, n=n, round.N = round.N)
    tbl_q_result <- tbl_q_result %>% mutate(variable_backup = variable) %>% separate(variable_backup, c("variable1", "variable2"), sep="($)")
    }
  if (length(tbl_c) > n.group){
    tbl_c_result <- ez_summarise_categorical(tbl = tbl_c, n=n, round.N = round.N)
    tbl_c_result <- tbl_c_result %>% mutate(variable_backup = variable) %>% separate(variable_backup, into = c("variable1", "variable2"), sep="_(?=[^_]*$)")
  }
  # Fix the naming
  if (!is.null(tbl_q_result) & !is.null(tbl_c_result)){
    tbl_q_result <- rename(tbl_q_result, mean_n = mean)
    tbl_c_result <- rename(tbl_c_result, mean_n = count)
    tbl_q_result <- rename(tbl_q_result, sd_p = sd)
    tbl_c_result <- rename(tbl_c_result, sd_p = p)
  }
  # Combine the results
  tbl_result <- rbind(tbl_q_result, tbl_c_result)

  # Sort the variables in the order the variables were provided
  # factorize variable1
  tbl_result$variable1 <- factor(tbl_result$variable1, levels = var.name)
  tbl_result <- eval(parse(text = paste0("tbl_result %>% arrange(",
                                         paste0(c("variable1", group.name, "variable2"), collapse = ", "),
                                         ")")))
  tbl_result <- tbl_result %>% select(-variable1, -variable2)
  return(tbl_result)
}




