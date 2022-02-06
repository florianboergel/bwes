# these are the results of the two experiments
exp1=c(12,20,16,23,23,17,14,26,15,20,19,21,12,16,21,23,13,21,13,11,19,15,18,18,19,23,17,18,18,20,19,17,20,23,22,18,19,27,15,16,20,20,19,21,19,13,11,19,18,18,10,17,11,17,18,22,20)
exp2=c(11,19,11,16,17,23,20,19,15,13,19,12,12,12,16,20,17,15,11,14,16,18,16,15,16,22,18,17,21,20,22,11,19,17,12,16,21,21,20,22,22,15,11,10,21,21,22,17,20,15,16,18,13,21,15,23)

acf(exp1)
acf(exp2)

?acf

acf_exp1 <- acf(exp1,plot=FALSE)
acf_exp1

acf_exp1$acf[2]

# calclate the autocorrelation function
acf1 = function(x) {
  acf(x, plot=FALSE)$acf[2]  
}
acf1(exp1)
acf1(exp2)

# create empty matrix
boot = matrix(NA,nrow=100000,ncol=length(exp1))
# fill it row by row
for (i in seq_len(100000)) {
    boot[i,] = sample(exp1,replace = TRUE)
}
# view the first rows
head(boot)

sample(c(1,2,3,4),replace=TRUE)

# now calculate autocorrelation for each of the rows
acf_bootstrap = apply(boot, 1, acf1)
print(acf_bootstrap)
# draw a histogram
hist(acf_bootstrap)

# get the percentiles
print("95% confidence interval for ACF in bootstrapped exp1:")
quantile(acf_bootstrap,probs = c(0.025,0.975))

print("ACF in exp2:")
print(acf1(exp2))


library(RNetCDF)
?var.get.nc
