#' 
#' @title Performs plotting of survival analysis curves.
#' @description returns a privacy preserving survival curve.
#' @details Serverside aggregate function {plotsurvfitDS} called by clientside function.
#' {ds.plotsurvfit}.
#' returns a privacy preserving survival curve from the server side environment.
#' This request is not disclosive as it is randomized.
#' For further details see help for {ds.plotsurvfit} function.
#' @param formula a character string which has the name of server-side survfit() object.
#'		This should be created using ds.survfit()
#' @param dataName character string of name of data frame
#' @return a privacy preserving survival curve from the server side environment.
#' @author Soumya Banerjee, Tom Bishop, Demetris Avraam, Paul Burton and DataSHIELD technical team (2021).
#' @export
plotsurvfitDS<-function(formula = NULL,
                        dataName = NULL
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
  # hard coded for now
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
      # can make noise a percentage of previous OR current value
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
      delta_noise <- stats::rnorm(n = 1, mean = 0, sd = percentage)
      survfit_model_variable$time[i_temp_counter_inner] <- survfit_model_variable$time[i_temp_counter_inner] - delta_noise
      
    }
    
  }
  
  return(survfit_model_variable)

}
#AGGREGATE FUNCTION
# plotsurvfitDS
