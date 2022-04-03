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
#' @param method_anonymization an integer. Method of anonymization to be used (3: smoothing). Default value is 3.
#' @param noise an integer. fraction of noise (between 0 and 1) to be added to original data. 
#'     Noise is added as a percentage of original value. 
#'     This is used for probabilistic anonymization.
#'     Default value is 0.03 
#' @param knn an integer. Number of nearest neighbours to be used for k nearest neighbours algorithm (for determinstic anonymization). 
#'     Default value is 20.
#' @return a privacy preserving survival curve from the server side environment.
#' @author Soumya Banerjee, Demetris Avraam, Paul Burton and Tom RP Bishop (2022).
#' @export
plotsurvfitDS<-function(formula = NULL,
                        dataName = NULL,
			method_anonymization = 3,
			noise = 0.03,
			knn = 20
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
  
  # get the value of the 'data' and 'weights' parameters provided as character on the client side
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
  if (method_anonymization == 3) 	
  {
      # TODO: make it depend on number of data points on X axis 	
      f_span = 0.30	 # useable span 0.3-0.55
      smoothed_survfit = stats::loess(survfit_model_variable$surv ~ survfit_model_variable$time, span = f_span)	
      
      # predict
      predict_smoothed_survfit = stats::predict(smoothed_survfit)  	
	  
      # TODO: modify last point and make sure not negative and not greater than previous point	
      # assign to surv variable the smoothed data	
      survfit_model_variable$surv = predict_smoothed_survfit
  }
  # end if  	

	
  # return modified survfit object
  return(survfit_model_variable)

}
#AGGREGATE FUNCTION
# plotsurvfitDS
