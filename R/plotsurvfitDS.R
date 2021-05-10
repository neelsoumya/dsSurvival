#' 
#' @title Performs plotting of survival analysis curves.
#' @description returns a privacy preserving survival curve.
#' @details Serverside aggregate function {plotsurvfitDS} called by clientside function.
#' {ds.plotsurvfit}.
#' returns a privacy preserving survival curve from the server side environment.
#' This request is not disclosive as it is randomized.
#' For further details see help for {ds.coxphSLMA} function.
#' @param formula a character string which has the name of server-side survfit() object.
#'		This should be created using ds.survfit()
#' @param dataName character string of name of data frame
#' @param weights vector of case weights
#' @param init vector of initial values of the iteration
#' @param ties character string specifying the method for tie handling.
#'          The Efron approximation is used as the default. Other options are
#'          'breslow' and 'exact'.
#' @param singular.ok Logical value indicating how to handle collinearity in the model matrix.
#'        Default is TRUE. If TRUE, the program will automatically skip over columns of the 
#'        X matrix that are linear combinations of earlier columns. In this case the coefficients
#'        of such columns will be NA and the variance matrix will contain zeros.
#' @param model logical value. If TRUE, the model frame is returned in component model. 
#' @param x logical value. If TRUE, the x matrix is returned in component x.
#' @param y logical value. If TRUE, the response vector is returned in component y.
#' @param control object of type survival::coxph.control() specifying iteration limit and other
#'        control options. Default is survival::coxph.control()
#' @return a summary of the Cox proportional hazards from the server side environment from the server side environment.
#' @author Soumya Banerjee, Tom Bishop, Demetris Avraam, Paul Burton and DataSHIELD technical team (2021).
#' @export
plotsurvfitDS<-function(formula = NULL,
                        dataName = NULL,
                        weights = NULL,
                        init = NULL,
                        ties = 'efron',
                        singular.ok = TRUE,
                        model = FALSE,
                        x = FALSE,
                        y = TRUE,
                        control = NULL
)
{
  
  errorMessage <- "No errors"
  
  #########################################################################
  # DataSHIELD MODULE: CAPTURE THE nfilter SETTINGS                       #
  thr <- listDisclosureSettingsDS()                                       #
  #nfilter.tab<-as.numeric(thr$nfilter.tab)                               #
  #nfilter.glm<-as.numeric(thr$nfilter.glm)                               #
  #nfilter.subset<-as.numeric(thr$nfilter.subset)                         #
  nfilter.string <- as.numeric(thr$nfilter.string)                        #
  nfilter.tab    <- as.numeric(thr$nfilter.tab)                           #
  nfilter.glm    <- as.numeric(thr$nfilter.glm)                           #
  nfilter.noise  <- as.numeric(thr$nfilter.noise)                         #
  #nfilter.stringShort<-as.numeric(thr$nfilter.stringShort)               #
  #nfilter.kNN<-as.numeric(thr$nfilter.kNN)                               #
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
  
  
  ###########################
  # disclosure checks
  ###########################
  
  # get survfit model
  survfit_model_variable = eval(parse(text=formula), envir = parent.frame())
  
  # set method to probabilistic
  # TODO: make arguments
  method_anonymization = 2
  noise = 0.03 # 0.0003 # 0.03 0.26
  
  # if probabilistic anonymization then generate and add noise	
  if (method_anonymization == 2)
  {	      
    
    # set study specific seed
    seed <- getOption("datashield.seed")
    if (is.null(seed))
    {
      stop("plotsurvfitDS requires a seed to be set and requires 'datashield.seed' R option to operate", call.=FALSE)
    }
    
    # if there is a seed, then set it
    set.seed(seed)	
    
    
    percentage <- noise
    
    
    ##########################################
    # Approach 1: add noise before plotting
    #
    # add noise to:
    # surv (i.e. proportion surviving)
    # time (times at which events occur, ie when the proportion changes)
    # this is for the y axis
    # and for time on x axis
    ##########################################
    for ( i_temp_counter_inner in c(2:length(survfit_model_variable$surv)) )
    {
      # current value, upper, lower at this index
      value_temp <- survfit_model_variable$surv[i_temp_counter_inner]
      upper_temp <- survfit_model_variable$upper[i_temp_counter_inner]
      lower_temp <- survfit_model_variable$lower[i_temp_counter_inner]
      
      # previous value, upper, lower
      prev_value_temp <- survfit_model_variable$surv[i_temp_counter_inner - 1]
      prev_upper_temp <- survfit_model_variable$upper[i_temp_counter_inner - 1]
      prev_lower_temp <- survfit_model_variable$lower[i_temp_counter_inner - 1]
      
      # add some noise 
      # TODO: make noise a percentage of previous OR current value
      # delta_noise <- abs(stats::rnorm(n = 1, mean = value_temp, sd = percentage * value_temp))
      delta_noise <- stats::rnorm(n = 1, mean = 0, sd = percentage)
      
      # SUBTRACT this noise from the PREVIOUS VALUE if it does not cause problems with monotonicity
      
      value_noise = value_temp - delta_noise
      upper_noise = upper_temp - delta_noise
      lower_noise = lower_temp - delta_noise
      
      if (prev_value_temp >= value_noise)
      {
        survfit_model_variable$surv[i_temp_counter_inner] <- value_noise
        survfit_model_variable$upper[i_temp_counter_inner] <- upper_noise
        survfit_model_variable$lower[i_temp_counter_inner] <- lower_noise
      }
      else
      {
        survfit_model_variable$surv[i_temp_counter_inner] = prev_value_temp
        survfit_model_variable$upper[i_temp_counter_inner] = prev_upper_temp
        survfit_model_variable$lower[i_temp_counter_inner] = prev_lower_temp
      }
      
      # survfit_model_variable$mono[i_temp_counter_inner] = prev_value_temp - survfit_model_variable$surv[i_temp_counter_inner]
      
      # new noise for x axis
      # needs more work, also monotonic
      delta_noise <- stats::rnorm(n = 1, mean = 0, sd = percentage)
      survfit_model_variable$time[i_temp_counter_inner] <- survfit_model_variable$time[i_temp_counter_inner] - delta_noise
      
    }
    
  }
  
  return(survfit_model_variable)

}
#AGGREGATE FUNCTION
# plotsurvfitDS
