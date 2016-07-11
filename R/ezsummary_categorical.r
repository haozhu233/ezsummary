#' Easily summarize categorical data
#'
#' @description \code{ezsummary_categorical()} summarizes categorical data.
#'
#' @param tbl A vector, a data.frame or a \code{dplyr} \code{tbl}.
#' @param n A T/F value; total counts of records. Default is
#' \code{FALSE}.
#' @param count A T/F value; count of records in each category.
#' Default is \code{TRUE}.
#' @param p A T/F value; proportion or percentage of records in each category.
#' Default is \code{TRUE}.
#' @param p_type A character string determining the output format of \code{p};
#' possible values are \code{decimal} and \code{percent}. Default value is
#' \code{decimal}.
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
#' @param P Deprecated; Will change the value of \code{p_type} if used in this
#' version.
#' @param round.N Deprecated; Will change the value of \code{rounding_type} if
#' used in this version.
#'
#' @examples
#' library(dplyr)
#' mtcars %>%
#'   group_by(am) %>%
#'   select(cyl, gear, carb) %>%
#'   ezsummary_categorical()
#'
#' mtcars %>%
#'   select(cyl, gear, carb) %>%
#'   ezsummary_categorical(n=TRUE, round.N = 2)
#'
#' @export

ezsummary_categorical <- function(
  tbl, n = FALSE, count = TRUE, p = TRUE, p_type = c("decimal", "percent"),
  digits = 3,
  rounding_type = c("round", "signif", "ceiling", "floor"),
  P = FALSE, round.N = 3,
  flavor = c("long", "wide"), fill = 0, unit_markup = NULL
  ){

  # Define the following variable to avoid NOTE on RMD check
  variable = value = analysis = var_origin = var_options = NULL

  # Option P and round.N have been deprecated. I'm still keeping the variables
  # here so people can still use them.
  if(P == TRUE){
    warning("Option P has been deprecated. Please use p_type instead.")
    p <- TRUE
    p_type <- "percent"
  }

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

  p_type <- match.arg(p_type)
  rounding_type <- match.arg(rounding_type)
  flavor <- match.arg(flavor)

  # Try to obtain grouping and variable information from the input tbl
  group_name <- attributes(tbl)$vars
  var_name <- attributes(tbl)$names
  if (!is.null(group_name)){
    group_name <- as.character(group_name)
    var_name <- var_name[!var_name %in% group_name]
  }
  n_group <- length(group_name)
  n_var <- length(var_name)

  if(n_group == 0 & flavor == "wide"){flavor <- "long"}

  available_tasks <- c(
    # count is calculated by default
    n = "sum(count)",
    count = "count",
    p = `if`(
      p_type == "decimal",
      paste0(rounding_type, "(count/sum(count)",
             `if`(rounding_type %in% c("round", "signif"),
                  paste0(", ", digits, ")"), ")")),
      p = paste0("paste0(", rounding_type, "(count/sum(count) * 100",
                 `if`(rounding_type %in% c("round", "signif"),
                      paste0(", ", digits, ")"), ")"), ", '%')")
    )
  )
  tasks_list <- available_tasks[c(n, count, p)]
  tasks_names <- names(tasks_list)

  tbl_summary <- lapply(
    var_name,
    function(x){
      summary_tmp <- tbl %>%
        group_by_(x, add = TRUE) %>%
        tally() %>%
        rename(count = n) %>%
        group_by_(.dots = group_name) %>%
        mutate_(.dots = tasks_list)
      summary_tmp[n_group + 1][[1]] <- paste(
        x, summary_tmp[n_group + 1][[1]], sep = "_")
      names(summary_tmp)[n_group + 1] <- "variable"
      summary_tmp
    }
  )

  category_sizes <- unlist(lapply(tbl_summary, nrow))

  tbl_summary <- tbl_summary %>% bind_rows()

  if(flavor == "wide"){
    tbl_summary <- tbl_summary %>%
      gather_("analysis", "value", tasks_names)

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

    tbl_summary <- tbl_summary %>%
      spread(analysis, value, fill = fill) %>%
      ungroup() %>%
      separate(variable, into = c("var_origin", "var_options"),
               remove = FALSE, sep = "_(?=[^_]+$)") %>%
      mutate(var_origin = factor(var_origin, levels = var_name)) %>%
      arrange_(c("var_origin", group_name)) %>%
      select(-var_origin, -var_options)

    category_sizes <- sapply(
      var_name,
      function(x){
        nrow(unique(ungroup(tbl)[x]))
      }
    )
  }

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

  attr(tbl_summary, "categories") <- rep(var_name, category_sizes)
  attr(tbl_summary, "flavor") <- flavor
  return(tbl_summary)
}

#' Shorthand for ezsummary_categorical
#' @rdname ezsummary_categorical
#' @export

ezsummary_c <- ezsummary_categorical
