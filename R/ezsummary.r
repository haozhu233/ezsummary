#' Quick and Easy summarise function
#'
#' @param tbl The input matrix of data you would like to analyze.
#' @param n n is a True/False switch that controls whether counts(N) should be included in
#' the output
#' @param round.N Rounding Number
#' @param flavor Flavor has two possible inputs: "long" and "wide". "Long" is the default
#' setting which will put grouping information on the left side of the table. It is more
#' machine readable and is good to be passed into the next analytical stage if needed.
#' "Wide" is more print ready (except for column names, which you can fix in the next step,
#' or fix in LaTex or packages like \code{\link[htmlTable]}). In the "wide" mode, the analyzed
#' variable will be the only "ID" variable and all the stats values will be presented ogranized
#' by the grouping variables (if any). If there is no grouping, the outputs of "wide" and
#' "long" will be the same.
#'
#' @export
ezsummary <- function(tbl, n=F, round.N=3, flavor = "long"){
  # If the input tbl is a vector, convert it to a 1-D data.frame and set it as a 'tbl' (dplyr).
  if(is.vector(tbl)){
    tbl <- as.tbl(as.data.frame(tbl))
    attributes(tbl)$names <- "unknown"
    warning("ezsummary cannot detect the naming information from an atomic vector. Please try to use something like 'select(mtcars, gear)' to replace mtcars$gear in your code.")
  }
  if(flavor != "long" & flavor !="wide"){warning('The value of flavor has to be either "long" or "wide". Now the input is evalued as if you entered "long" by default. Please revise your function inputs!')}
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
    tbl_q_result <- ezsummary_quantitative(tbl = tbl_q, n=n, round.N = round.N)
    tbl_q_result <- tbl_q_result %>% mutate(variable_backup = variable) %>% separate(variable_backup, c("variable1", "variable2"), sep="($)")
    }
  if (length(tbl_c) > n.group){
    tbl_c_result <- ezsummary_categorical(tbl = tbl_c, n=n, round.N = round.N)
    tbl_c_result <- tbl_c_result %>% mutate(variable_backup = variable) %>% separate(variable_backup, into = c("variable1", "variable2"), sep="_(?=[^_]*$)")
  }
  # Fix the naming
  if (!is.null(tbl_q_result) & !is.null(tbl_c_result)){
    tbl_q_result <- rename(tbl_q_result, mean_n = mean)
    tbl_c_result <- rename(tbl_c_result, mean_n = count)
    tbl_q_result <- rename(tbl_q_result, sd_p = sd)
    tbl_c_result <- rename(tbl_c_result, sd_p = p)
    # assign mean_n as factor
    tbl_q_result$mean_n <- factor(tbl_q_result$mean_n)
    tbl_c_result$mean_n <- factor(tbl_c_result$mean_n)
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

  if(flavor == "wide"){
    for(i in 1:n.group){
      tbl_result[,group.name[i]] <- paste(group.name[i], unlist(tbl_result[,group.name[i]]), sep=".")
    }
    tbl_result <- tbl_result %>% melt(id.var = c(group.name, "variable"), variable.name = "stats.var")
    dcast_formula <- paste0("dcast(tbl_result, variable ~ ", paste0(c(group.name, "stats.var"), collapse = " + "), ")")
    tbl_result <- eval(parse(text = dcast_formula))
  }
  return(tbl_result)
}




