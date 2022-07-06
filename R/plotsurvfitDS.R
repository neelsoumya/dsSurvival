#' 
#' @title Performs plotting of survival analysis curves.
#' @description returns a privacy preserving survival curve.
#' @details Serverside aggregate function {plotsurvfitDS} called by clientside function.
#' {ds.plotsurvfit}.
#' returns a privacy preserving survival curve from the server side environment.
#' This request is not disclosive as it is randomized.
#' For further details see help for {ds.plotsurvfit} function.
#' @param formula a character string which has the name of server-side survfit() object.
#'		This should be created using a call to ds.survfit()
#' @param dataName character string of name of data frame
#' @return a privacy preserving survival curve from the server side environment.
#' @author Soumya Banerjee, Demetris Avraam, Paul Burton and Tom RP Bishop (2022).
#' @export
plotsurvfitDS<-function(formula = NULL,
                        dataName = NULL #,
			# method_anonymization = 3,
			# noise = 0.03,
			# knn = 20
                       )
{
  
  errorMessage <- "No errors"
  
  #########################################################################
  # DataSHIELD MODULE: CAPTURE THE nfilter SETTINGS                       #
  # thr <- listDisclosureSettingsDS()                                     #
  #nfilter.tab<-as.numeric(thr$nfilter.tab)                               #
  #nfilter.glm<-as.numeric(thr$nfilter.glm)                               #
  #nfilter.subset<-as.numeric(thr$nfilter.subset)                         #
  # nfilter.string <- as.numeric(thr$nfilter.string)                      #
  #nfilter.tab    <- as.numeric(thr$nfilter.tab)                          #
  #nfiter.glm    <- as.numeric(thr$nfilter.glm)                           #
  #nfilter.noise  <- as.numeric(thr$nfilter.noise)                        #
  #nfilter.stringShort<-as.numeric(thr$nfilter.stringShort)               #
  #nfilter.kNN    <- as.numeric(thr$nfilter.kNN)                          #
  #datashield.privacyLevel<-as.numeric(thr$datashield.privacyLevel)       #
  #########################################################################
  
  # get the value of the 'data' parameter provided as character on the client side
  if(is.null(dataName))
  {
    dataTable <- NULL 
  }
  else
  {
    dataTable <- eval(parse(text=dataName), envir = parent.frame())
  }
  
  # check if formula is set
  if (is.null(formula))
  {
    stop("The formula must be set for use in survival::coxph()", call.=FALSE)
  }
  

  # get survfit model
  survfit_model_variable = eval(parse(text=formula), envir = parent.frame())
  
  
  ################################################
  # Approach 3:	
  # Smoothing option
  #  using LOESS
  #   (Locally Weighted Scatterplot Smoothing)	
  ################################################
  # if (method_anonymization == 3) 	
  # {
      # TODO: make it depend on number of data points on X axis 	
      # f_span = 0.30	 # useable span 0.3-0.55
      # smoothed_survfit = stats::loess(survfit_model_variable$surv ~ survfit_model_variable$time, span = f_span)	
      
      # predict
      # predict_smoothed_survfit = stats::predict(smoothed_survfit)  	
	  
      # TODO: modify last point and make sure not negative and not greater than previous point	
      # assign to surv variable the smoothed data	
      # TODO: use automated way to determine span loess.as() in fANCOVA package 	
      # survfit_model_variable$surv = predict_smoothed_survfit
  # }
  # end if  	

  ##########################################################	
  # LOESS smoothing fit with automated span determination
  ##########################################################	
  smoothed_survfit = fANCOVA::loess.as(survfit_model_variable$time, survfit_model_variable$surv, plot=FALSE)
	
  # predict
  predict_smoothed_survfit = stats::predict(smoothed_survfit)  	

  # overwrite surv field in survfit object	
  survfit_model_variable$surv = predict_smoothed_survfit
	
  ########################################################	
  # remove or perturb potentially disclosive elements	
  ########################################################	
  # survfit_model_variable$n.event = NULL
  # survfit_model_variable$n.risk  = NULL

  # smoother for n.event	
  temp_fit_1 = fANCOVA::loess.as(survfit_model_variable$time, survfit_model_variable$n.event, plot=FALSE)	
  # predict
  temp_fit_1_predict = stats::predict(temp_fit_1)
  # overwrite	
  survfit_model_variable$n.event = temp_fit_1_predict
	
  # smoother for n.risk
  temp_fit_2 = fANCOVA::loess.as(survfit_model_variable$time, survfit_model_variable$n.risk, plot=FALSE)	
  # predict
  temp_fit_2_predict = stats::predict(temp_fit_2)	
  # overwrite
  survfit_model_variable$n.risk = temp_fit_2_predict
	
	
  # return modified survfit object
  return(survfit_model_variable)

}
#AGGREGATE FUNCTION
# plotsurvfitDS
