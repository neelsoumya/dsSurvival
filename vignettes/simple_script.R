#####################################################
# Simple script demonstrating how to use dsSurvival
#
# Usage:
#         R --no-save < simple_script.R
#####################################################


library(knitr)
library(rmarkdown)
library(tinytex)
library(survival)
library(metafor)
library(ggplot2)
library(dsSurvivalClient)
require('DSI')
require('DSOpal')
require('dsBaseClient')

builder <- DSI::newDSLoginBuilder()

builder$append(server="server1", url="https://opal-sandbox.mrc-epid.cam.ac.uk",
                user="dsuser", password="P@ssw0rd", 
               table = "SURVIVAL.EXPAND_NO_MISSING1")

builder$append(server="server2", url="https://opal-sandbox.mrc-epid.cam.ac.uk",
               user="dsuser", password="P@ssw0rd", 
               table = "SURVIVAL.EXPAND_NO_MISSING2")

builder$append(server="server3", url="https://opal-sandbox.mrc-epid.cam.ac.uk",
               user="dsuser", password="P@ssw0rd", 
               table = "SURVIVAL.EXPAND_NO_MISSING3")          

logindata <- builder$build()

connections <- DSI::datashield.login(logins = logindata, assign = TRUE, symbol = "D") 



ds.asNumeric(x.name = "D$cens",
             newobj = "EVENT",
             datasources = connections)
         
ds.asNumeric(x.name = "D$survtime",
             newobj = "SURVTIME",
             datasources = connections)
             
             
ds.asFactor(input.var.name = "D$time.id",
            newobj = "TID",
            datasources = connections)
            
ds.log(x = "D$survtime",
       newobj = "log.surv",
       datasources = connections)
       

ds.asNumeric(x.name = "D$starttime",
             newobj = "STARTTIME",
             datasources = connections)
             
ds.asNumeric(x.name = "D$endtime",
             newobj = "ENDTIME",
             datasources = connections)
             

dsSurvivalClient::ds.Surv(time='STARTTIME', time2='ENDTIME', 
                      event = 'EVENT', objectname='surv_object',
                      type='counting')
              
coxph_model_full <- dsSurvivalClient::ds.coxph.SLMA(formula = 'surv_object~D$age+D$female')



dsSurvivalClient::ds.coxphSLMAassign(formula = 'surv_object~D$age+D$female',
                            objectname = 'coxph_serverside')
                
dsSurvivalClient::ds.cox.zphSLMA(fit = 'coxph_serverside')

dsSurvivalClient::ds.coxphSummary(x = 'coxph_serverside')

dsSurvivalClient::ds.coxphSummary(x = 'coxph_serverside')



input_logHR = c(coxph_model_full$server1$coefficients[1,2], 
        coxph_model_full$server2$coefficients[1,2], 
        coxph_model_full$server3$coefficients[1,2])
        
input_se    = c(coxph_model_full$server1$coefficients[1,3], 
        coxph_model_full$server2$coefficients[1,3], 
        coxph_model_full$server3$coefficients[1,3])
        
meta_model <- metafor::rma(input_logHR, sei = input_se, method = 'REML')


metafor::forest.rma(x = meta_model, digits = 4) 

dsSurvivalClient::ds.plotsurvfit(formula = 'survfit_object')

DSI::datashield.logout(conns = connections)
