#' Title
#'
#' @param survfit_object 
#'
#' @return
#' @export
#'
#' @examples
life.tableDS <- function(survfit_object){
  survfit_object_re <- summary(
    survfit_object, times = seq(
      plyr::round_any(min(survfit_object$time), 1, floor), 
      plyr::round_any(max(survfit_object$time), 1, ceiling), 
      1 # TODO This should be a function argument!
    )
  )
  df <- data.frame(
    time = survfit_object_re$time,
    n.risk = survfit_object_re$n.risk,
    n.event = survfit_object_re$n.event
  )
  if(!is.null(survfit_object_re$strata)){
    split_vector <- survfit_object_re$strata
    df_list <- split(df, split_vector)
    names(df_list) <- levels(survfit_object_re$strata)
  } else {
    df_list <- list(df)
    names(df_list) <- "life.table_no_strata"
  }
  return(df_list)
}
