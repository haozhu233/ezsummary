#' Simple Summary for Quantitative/binary variables
#'
#' @description Function ezsummary_quantitative provides simple summary (Mean
#' and standard deviation with/without N) for quantitative data while function
#' ezsummary_binary provides simple summary (freq and percentage with/without
#' total counts) for binary data. These two function are simply wrappers
#' outside of a summarise_each function. If we just want to know the most basic
#' statistical summary, this function can save us some typing time. It also
#' provide the option to include number of subjects inside the analyses.
#'
#' @param tbl The input matrix of data you would like to analyze.
#' @param n n is a True/False switch that controls whether counts(N) should be
#' included in the output
#' @param mean a T/F switch to control whether mean should be calculated
#' @param sd a T/F switch to control whether standard deviation should be
#' calculated
#' @param sem a T/F switch to control whether standard error of the mean should
#' be calculated
#' @param median a T/F switch to control whether median should be calculated
#' @param quantile a T/F switch to control whether 0%, 25%, 50%, 75% and 100%
#' quantile should be calculated
#' @param round.N Rounding Number
#' @param flavor Flavor has two possible inputs: "long" and "wide". "Long" is
#' the default setting which will put grouping information on the left side of
#' the table. It is more machine readable and is good to be passed into the
#' next analytical stage if needed. "Wide" is more print ready (except for
#' column names, which you can fix in the next step, or fix in LaTex or
#' packages like \code{htmlTable}). In the "wide" mode, the analyzed variable
#' will be the only "ID" variable and all the stats values will be presented
#' ogranized by the grouping variables (if any). If there is no grouping, the
#' outputs of "wide" and "long" will be the same.
#' @param unit_markup When unit_markup is not NULL, it will call the ezmarkup
#' function and perform column combination here. To make everyone's life
#' easier, I'm using the term "unit" here. Each unit mean each group of
#' statistical summary results. If you want to know mean and stand deviation,
#' these two values are your units so you can put something like "[. (.)]" there
#'
#' @return It will return in the same format as a summarise_each function does
#'
#' @examples
#' library(dplyr)
#' mtcars %>% group_by(am) %>% select(mpg, wt, qsec) %>% ezsummary_quantitative()
#'
#' @importFrom stats na.omit sd median quantile
#' @export
ezsummary_quantitative <- function(
  tbl, total = FALSE, n = FALSE, missing = FALSE,
  mean = TRUE, sd = TRUE, sem = FALSE, median = FALSE, quantile = FALSE,
  extra = NULL,
  digits = getOption("digits"), rounding_type = "round",
  P = FALSE, round.N=3,
  flavor = "long", unit_markup = NULL
){

  if(round.N != 3){
    warning("Option round.N has been deprecated. Please use 'digits' instead.")
    digits <- round.N
  }

  if(is.vector(tbl)){
    tbl <- as.tbl(as.data.frame(tbl))
    attributes(tbl)$names <- "unknown"
    warning('ezsummary cannot detect the naming information from an atomic ',
            'vector. If you want to have full naming information, please ',
            'pass the value in as a data frame using `select` from dplyr.')
  }

  if(!flavor %in% c("long", "wide")){
    flavor <- "long"
    warning(
      '`flavor` has to be either "long" or "wide". The default value "long" ',
      'is used here. ')
  }

  # Try to obtain grouping and variable information from the input tbl
  group_name <- attributes(tbl)$vars
  var_name <- attributes(tbl)$names
  if (!is.null(group_name)){
    group_name <- as.character(group_name)
    var_name <- var_name[!var_name %in% group_name]
  }
  n_group <- length(group_name)
  n_var <- length(var_name)

  # Generate a list of tasks needed to be done
  available_tasks <- c(
    total = "length(.)",
    n = "length(stats::na.omit(.))",
    missing = "sum(is.na(.))",
    mean = "mean(., na.rm = TRUE)",
    sd = "stats::sd(., na.rm = TRUE)",
    sem = "stats::sd(., na.rm = TRUE) / sqrt(length(stats::na.omit(.)))",
    median = "stats::median(., na.rm = TRUE)",
    q0 = "stats::quantile(., na.rm = TRUE)[1]",
    q25 = "stats::quantile(., na.rm = TRUE)[2]",
    q50 = "stats::quantile(., na.rm = TRUE)[3]",
    q75 = "stats::quantile(., na.rm = TRUE)[4]",
    q100 = "stats::quantile(., na.rm = TRUE)[5]"
  )

  tasks_list <- c(
    available_tasks[
      c(total, n, missing, mean, sd, sem, median,
        quantile, quantile, quantile, quantile, quantile)
      ],
    extra
  )

  tasks_names <- names(tasks_list)

  tbl_summary_raw <- tbl %>%
    summarise_each(funs_(tasks_list))

  if(n_group == 0){
    tbl_summary <- tbl_summary_raw %>%
      gather(var, value)
  }else{
    tbl_summary <- tbl_summary_raw %>%
      gather(var, value, seq(-1, -n_group))
  }

  tbl_summary <- tbl_summary %>%
    mutate(value = `if`(
      rounding_type %in% c("round", "signif"),
      eval(call(rounding_type, value, digits)),
      eval(call(rounding_type, value))
    )) %>%
    separate(var, into = c("var", "analysis"))



  if(flavor == "wide" & n_group != 0){
    tbl_summary[group_name] <- sapply(
      group_name, function(x){paste(x, tbl_summary[x][[1]], sep = ".")}
    )

    tbl_summary <- tbl_summary %>%
      unite_("analysis", c(group_name, "analysis"))

    group_reorder <- sapply(group_name, function(x){
      paste(x, attr(tbl, "labels")[x][[1]], sep = ".")
    }) %>%
      apply(1, paste, collapse = "_")
    tasks_names <- c(sapply(group_reorder, function(x){
      paste(x, tasks_names, sep = "_")
    }))
  }

  tbl_summary <- tbl_summary %>%
    spread(analysis, value) %>%
    ungroup() %>%
    mutate(var = factor(var, levels = setdiff(var_name, group_name))) %>%
    arrange_(c("var", group_name))

  tbl_summary <- tbl_summary[c(
    `if`(flavor == "long" & n_group != 0, group_name, NULL),
    "var", tasks_names
    )]

  return(tbl_summary)

  # # Ezmarkup
  # if(!is.null(unit_markup)){
  #   ezmarkup_formula <- paste0(paste0(rep(".", n.group), collapse = ""), ".", unit_markup)
  #   table_export <- ezmarkup(table_export, ezmarkup_formula)
  # }
  #
  # attributes(table_export)$vars <- group.name
  # attributes(table_export)$n.group <- n.group
  # attributes(table_export)$n.var <- n.var
  # attr(table_export, "class") <- c("tbl_df", "tbl", "data.frame")
  # attr(table_export, "group_sizes") <- NULL
  # attr(table_export, "biggest_group_size") <- NULL
  # return(table_export)
}

