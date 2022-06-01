#' 
#' @title Returns variance-covariance matrix of Cox Proportional Hazard model.
#' @description returns a variance-covariance matrix of Cox Proportional Hazard model from the server side environment.
#' @details Serverside aggregate function {vcovDS.coxph} called by clientside function 
#' {ds.vcov.coxph}.
#' returns a list which contains a variance-covariance matrix for a Cox model.
#' This request is not disclosive, because the disclosure checks should be performed in the main function for building
#' the Cox model (e.g. checking for over saturation).
#' For further details see help for the native {vcov} function.
#' @param object name of server-side coxph object.
#' @return a variance-covariance matrix.
#' @author Soumya Banerjee and Tom Bishop (2022).
#' @export
vcovDS.coxph<-function(object=NULL)
{

  if (is.null(object))
  {
    stop("Please provide the name of a survival::coxph object", call.=FALSE)
  }

  surv_obj<-eval(parse(text=object), envir = parent.frame())
  
  if (class(surv_obj)!="coxph")
  {
    stop("Object is not of class survival::coxph, please check the name", call.=FALSE)
  }

  vcov_res <- stats::vcov(surv_obj)
  
  return(vcov_res)
  
  
}
#AGGREGATE FUNCTION
# vcovDS.coxph
