###########################################
# Script to build manuals and test
#
# Usage:
#   R --no-save < build_man_test.R
#
###########################################

###################
# load libraries
###################
library(devtools)
library(testthat)
library(dsBase)
library(dsBaseClient)
require('DSI')
require('DSOpal')

##################
# build manuals
##################
devtools::build_manual()

##################
# build vignettes
##################
devtools::build_vignettes()

##################
# Testing
##################
devtools::test()

##################
# clean up
##################
gc()

