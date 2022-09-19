##########################################################################
# Simple script to load survival data and show 
#  survival functionality
#
# Authors: Soumya Banerjee, Tom Bishop, Demetris Avraam, Paul Burton
##########################################################################

####################
# Load libraries
####################
library(survival)
library(RANN)
library(fANCOVA)

##############
# Load data
##############
file <- read.csv(file = "expand_no_missing_study1.csv", header = TRUE, stringsAsFactors = FALSE)
# file <- read.csv(file = "https://raw.githubusercontent.com/neelsoumya/survival_curve_privacy_prototype/main/expand_no_missing_study1.csv", header = TRUE, stringsAsFactors = FALSE)
lung
bladder
veteran
cgd
colon
diabetic
gbsg
heart
jasa
mgus
myeloid
nafld1


##################
# Plotting
##################
survObj <- Surv(time=lung$time, event=lung$status==2, type='right')
survObj <- with(veteran,Surv(time, status))
# subsample

# TODO: parametrize 50 and vary that and figuire out a
survObj <- survObj[1:10]
no_noise <- survfit(survObj ~ 1)

# make a copy
with_noise <- no_noise

# original survival curve
plot(no_noise, main= "raw data")

#noise = 0.0003 # 0.03 0.26
noise = 0.0001




##########################################
# Approach 1: probabilistic anonymization
#     add noise before plotting
#
# add noise to:
# surv (i.e. proportion surviving)
# time (times at which events occur, ie when the proportion changes)
# this is for the y axis
# and for time on x axis
##########################################

sd = var(with_noise$time)^0.5

for ( i_temp_counter_inner in c(2:length(with_noise$surv)) )
{
  delta_noise_time <- stats::rnorm(n = 1, mean = 0, sd = noise*sd)
  # with_noise$time[i_temp_counter_inner] <- with_noise$time[i_temp_counter_inner] + delta_noise
  
  # previous value time
  prev_value_temp_time <- with_noise$time[i_temp_counter_inner - 1]
  # current value temp time
  curr_value_temp_time <- with_noise$time[i_temp_counter_inner]
  # proposed value of time with noise subtracted
  value_noise_time_proposed = curr_value_temp_time + (curr_value_temp_time*delta_noise_time)
  
  if (prev_value_temp_time <= value_noise_time_proposed)
  {
    # if previous value time is less then proposed value then ok 
    # since time is supposed to be increasing
    
    # set this value to current time
    with_noise$time[i_temp_counter_inner] = value_noise_time_proposed
    
  }
  else
  {
    # set to previous time value
    with_noise$time[i_temp_counter_inner] = prev_value_temp_time
  }
  
  
  
}

# modified survival curve
plot(with_noise, main = "probabilistic anonymisation", xlab = 'Time', ylab = 'Survival fraction')



##################################################
# Approach 3: deterministic anonymization take 2
#
##################################################

##################
# Anonymise survival times using the deterministic anonymisation
##################

knn <- 20
with_knn <- no_noise

# Step 1: Standardise the variable
time.standardised <- (with_knn$time-mean(with_knn$time))/stats::sd(with_knn$time)

# Step 2: Find the k-1 nearest neighbours of each data point
nearest <- RANN::nn2(time.standardised, k = knn)

# Step 3: Calculate the centroid of each n nearest data points
time.centroid <- matrix()
for (i in 1:length(with_knn$time))
{
  time.centroid[i] <- mean(time.standardised[nearest$nn.idx[i,1:knn]])
}

# Step 4: Calculate the scaling factor
time.scalingFactor <- stats::sd(time.standardised)/stats::sd(time.centroid)

# Step 5: Apply the scaling factor to the centroids
time.masked <- time.centroid * time.scalingFactor

# Step 6: Shift the centroids back to the actual position and scale of the original data
SURVTIME_anon <- (time.masked * stats::sd(with_knn$time)) + mean(with_knn$time)

# modofy time in survfit object (instead of original time)
with_knn$time <- SURVTIME_anon

# TODO: commenting out these to have no survfit call
#with_noise.anon <- survfit(Surv(SURVTIME_anon, EVENT) ~ 1)
#lines(with_noise.anon, col='red', add=TRUE)
# with_noise_determ <- with_noise.anon
#plot(with_noise_determ)

# if time needs adjustment, if min is less than 0 for example
#  then adjust and translate everything
if (min(with_knn$time) < 0)
{
  with_knn$time <- with_knn$time - min(with_knn$time)  
}

plot(with_knn, main = "deterministic anonymisation", xlab = 'Time', ylab = 'Survival fraction')


##################
# LOESS smoothing
##################

# TODO:
span = a /number of points

loess10 = loess(no_noise$surv ~ no_noise$time, span=0.10)
smoothed10 <- predict(loess10)
loess25 = loess(no_noise$surv ~ no_noise$time, span=0.25)
smoothed25 <- predict(loess25)
plot(no_noise)
plot(no_noise$surv, x=no_noise$time, type="l", main="Loess Smoothing and Prediction", xlab="time", ylab="surv")
lines(smoothed10, x=no_noise$time, col="red")
lines(smoothed25, x=no_noise$time, col="green")

################################
# automated LOESS smoothing
################################
# on data fit model
# no_noise is survfit object
loess_as_fit <- fANCOVA::loess.as(no_noise$time, no_noise$surv, plot = TRUE)

# predict
smoothed_loess_as = stats::predict(loess_as_fit)

# assign to survfit object and modify it
# create temp variable
no_noise_temp_loess_as <- no_noise
no_noise_temp_loess_as$surv <- smoothed_loess_as


# plot
plot(no_noise_temp_loess_as$surv, x = no_noise_temp_loess_as$time, main = "Ablation study automatic LOESS", xlab = 'Time', ylab = 'Fraction survived')



##################################################
# differential privacy
# bonomi et al
##################################################


N = no_noise$n
T = 1000
epsilon = 2
partition = ceiling(log(min(N,T),2)/epsilon)
partition = 3

acc = 0
label = 1
no_noise$label = c(1:length(no_noise$time))


# function to define partitioning groups
for (i in 1:length(no_noise$time)){
  # need to add partition noise to take half of half the budget
  acc = acc + no_noise$n.event[i] + no_noise$n.censor[i]
  if (acc > partition){
    label = label + 1
    acc = 0
  }
  no_noise$label[i] = label
  
}

my_df = data.frame(groups = no_noise$label, time = no_noise$time, n.event = no_noise$n.event,
                   n.censor = no_noise$n.censor, n.risk = no_noise$n.risk)

library(dplyr)

# section to sum up events within a partition - no noise yet
my_df2 <- my_df %>%
  group_by(groups) %>%
  summarise(
    across(.cols = time, .fns = max),
    across(.cols = c(n.event,n.censor), .fns = sum)
  ) %>% arrange(time)

my_df2$cum_sum_censor = cumsum(my_df2$n.censor)
my_df2$cum_sum_event = cumsum(my_df2$n.event)
# add half of half the budget of noise to these

# function to generate binary representation of the partition number

number2binary = function(number, noBits) {
  binary_vector = rev(as.numeric(intToBits(number)))
  if(missing(noBits)) {
    return(binary_vector)
  } else {
    binary_vector[-(1:(length(binary_vector) - noBits))]
  }
}

# recursive function to create a binary tree like structure
binarise2 <- function(N, the_list)
{
  tree_level = c()
  for (i in seq(2,length(N),2)){
    
    part_sum = N[i]+N[i-1]
    # trick for end of odd length N, keep it until the end
    if ((length(N) - i)==1) {
      tree_level = c(tree_level,part_sum,N[i+1])
    }
    else {tree_level = c(tree_level,part_sum)}
    
  }
  the_list = append(the_list, list(tree_level))
  if (length(tree_level) == 1)
    return(the_list)
  else
    binarise2(tree_level, the_list)
}

#then go through and apply remaining budget as noise to the intermediate counts

test = c(1,2,0,3,1,1,0,1,3)
test= my_df2$n.event
#put the first tree level in a list and then pass this to the tree generating function
my_list = list(test)
final_list = binarise2(test, my_list)
final_list = rev(final_list)

#this for loop uses the binary representation of the partition index to locate the required
# nodes in the binary tree structure and add them together
depth = length(final_list)
duration = length(test)
results = c()
for (i in 1:duration){
  num = number2binary(i, depth)
  total = 0
  for (j in depth:1){
    if (num[j] ==1) {
      loc = floor(i/2^(depth-j))
      total = total + final_list[[j]][loc]
    }
  }
  
  results = c(results, total)
}

