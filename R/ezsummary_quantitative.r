#' Easily summarize quantitative data
#'
#' @description \code{ezsummary_quantitative()} summarizes quantitative data.
#'
#' @param tbl A vector, a data.frame or a \code{dplyr} \code{tbl}.
#' @param total a T/F value; total counts of records including both missing
#' and read data records. Default is \code{FALSE}.
#' @param n A T/F value; total counts of records that is not missing. Default
#' is \code{FALSE}.
#' @param missing a T/F value; total counts of records that went missing(
#' \code{NA}). Default is \code{FALSE}.
#' @param mean A T/F value; the average of a set of data. Default value is
#' \code{TRUE}.
#' @param sd A T/F value; the standard deviation of a set of data. Default value
#' is \code{TRUE}.
#' @param sem A T/F value; the standard error of the mean of a set of data.
#' Default value is \code{FALSE}.
#' @param median A T/F value; the median of a set of data. Default value is
#' \code{FALSE}.
#' @param quantile A T/F value controlling 5 outputs; the 0\%, 25\%, 50\%, 75\%
#' and 100\% percentile of a set of data. Default value is \code{FALSE}.
#' @param extra A character vector offering extra customizability to this
#' function. Please see Details for detail.
#' @param digits A numeric value determining the rounding digits; Replacement
#' for \code{round.N}. Default setting is to read from \code{getOption()}.
#' @param rounding_type A character string determining the rounding method;
#' possible values are \code{round}, \code{signif}, \code{ceiling} and
#' \code{floor}. When \code{ceiling} or \code{floor} is selected, \code{digits}
#' won't have any effect.
#' @param flavor A character string with two possible inputs: "long" and "wide".
#' "Long" is the default setting which will put grouping information on the left
#' side of the table. It is more machine readable and is good to be passed into
#' the next analytical stage if needed. "Wide" is more print ready (except for
#' column names, which you can fix in the next step, or fix in LaTex or
#' packages like \code{htmlTable}). In the "wide" mode, the analyzed variable
#' will be the only "ID" variable and all the stats values will be presented
#' ogranized by the grouping variables (if any). If there is no grouping, the
#' outputs of "wide" and "long" will be the same.
#' @param fill If set, missing values created by the "wide" flavor will be
#' replaced with this value. Please check \code{\link[tidyr]{spread}} for
#' details. Default value is \code{0}
#' @param unit_markup When unit_markup is not NULL, it will call the ezmarkup
#' function and perform column combination here. To make everyone's life
#' easier, I'm using the term "unit" here. Each unit mean each group of
#' statistical summary results. If you want to know mean and stand deviation,
#' these two values are your units so you can put something like "[. (.)]" there
#' #' @param P Deprecated; Will change the value of \code{p_type} if used in this
#' version.
#' @param round.N Deprecated; Will change the value of \code{rounding_type} if
#' used in this version.
#'
#' @examples
#' library(dplyr)
#' mtcars %>%
#'   group_by(am) %>%
#'   select(mpg, wt, qsec) %>%
#'   ezsummary_quantitative()
#'
#' @importFrom stats na.omit sd median quantile
#' @export

ezsummary_quantitative <- function(
  tbl, total = FALSE, n = FALSE, missing = FALSE,
  mean = TRUE, sd = TRUE, sem = FALSE, median = FALSE, quantile = FALSE,
  extra = NULL,
  digits = 3,
  rounding_type = c("round", "signif", "ceiling", "floor"),
  round.N=3,
  flavor = c("long", "wide"), fill = 0, unit_markup = NULL
){

  # Define the following variable to avoid NOTE on RMD check
  variable = value = analysis = NULL

  if(round.N != 3){
    warning("Option round.N has been deprecated. Please use 'digits' instead.")
    digits <- round.N
  }

  rounding_type <- match.arg(rounding_type)
  flavor <- match.arg(flavor)

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

  if(n_group == 0 & flavor == "wide"){flavor <- "long"}

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
    tbl_summary <- suppressWarnings(gather(tbl_summary_raw, variable, value))
  }else{
    tbl_summary <- tbl_summary_raw %>%
      gather(variable, value, seq(-1, -n_group))
  }

  tbl_summary <- tbl_summary %>%
    mutate(value = `if`(
      rounding_type %in% c("round", "signif"),
      eval(call(rounding_type, value, digits)),
      eval(call(rounding_type, value))
    ))

  if(length(tasks_list) == 1){
    tbl_summary["analysis"] <- tasks_names
  }else{
    if(n_var == 1){
      names(tbl_summary)[names(tbl_summary) == "variable"] <- "analysis"
      tbl_summary["variable"] <- var_name
    }else{
      tbl_summary <- tbl_summary %>%
        separate(variable, into = c("variable", "analysis"),
                 sep = "_(?=[^_]+$)")
    }
  }

  if(flavor == "wide"){
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
    spread(analysis, value, fill = fill) %>%
    ungroup() %>%
    mutate(variable = factor(variable, levels = setdiff(var_name, group_name))) %>%
    arrange_(c("variable", group_name))

  tbl_summary <- tbl_summary[c(
    `if`(flavor == "long" & n_group != 0, group_name, NULL),
    "variable", tasks_names
    )]

  # Ezmarkup
  if(!is.null(unit_markup)){
    if(flavor == "wide" & n_group != 0){
      ezmarkup_formula <- paste0(
        ".", paste0(rep(unit_markup, nrow(attr(tbl, "labels"))), collapse = ""))
    }else{
      ezmarkup_formula <- paste0(paste0(rep(".", n_group), collapse = ""),
                                 ".", unit_markup)
    }
    tbl_summary <- ezmarkup(tbl_summary, ezmarkup_formula)
  }

  attr(tbl_summary, "flavor") <- flavor

  return(tbl_summary)
}

#' @rdname ezsummary_quantitative
#' @export
ezsummary_q <- ezsummary_quantitative
