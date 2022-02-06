Cyano_rec <- read.csv("../Data/Biomarker_Faeroe.csv",dec=',',header=TRUE,sep="\t")
head(Cyano_rec)
plot(Cyano_rec)

# Fit the linear model
my_lm = lm(formula = Cya~Age,data=Cyano_rec)
# print a summary of the model fit
summary(my_lm)
# plot the data and the fitted model
plot(Cyano_rec$Age, Cyano_rec$Cya)
lines(Cyano_rec$Age,predict(my_lm,Cyano_rec))
# print the uncertainty interval for the slope
confint(my_lm)

plot(resid(my_lm))
hist(resid(my_lm))

acf(resid(my_lm))

library("nlme")
# do generalised least-squares fit
my_gls = gls(Cya~Age,data=Cyano_rec,correlation = corCAR1(form=~Age))
summary(my_gls)
# plot the data and the fitted model
plot(Cyano_rec$Age, Cyano_rec$Cya)
lines(Cyano_rec$Age,predict(my_gls,Cyano_rec))
# print the uncertainty interval for the slope
confint(my_gls)

# Three types of residuals:
# "response"     = the full residuals epsilon_n
# "standardized" = divided by standard deviation sigma
# "normalized"   = divided by standard deviation sigma and corrected for assumed autocorrelation
my_residuals = resid(my_gls,type="normalized")

plot(my_residuals)
hist(my_residuals)
acf(my_residuals)

# plot the data and the fitted model
plot(Cyano_rec$Age, Cyano_rec$Cya)
lines(Cyano_rec$Age,predict(my_gls,Cyano_rec))

x_values = c(0,1,2,3)
y_values = c(1,2,4,1)
plot(x_values,y_values)

slopes = c(-1,2,0,-3)
my_splinefunction = splinefunH(x=x_values, y=y_values, m=slopes)  # determine spline function
x_axis = seq(from=0,to=3,by=0.1)                                  # define an x axis vector
my_spline = my_splinefunction(x_axis)                             # apply the function to the x values to obtain y values

# now plot the spline as line and the knots as points
plot(x_axis,my_spline,type="l")
points(x_values,y_values,col="red",pch=15)

# load the library
library("mgcv")
# fit a gam model
x_values=seq(1880,2020,by=20)
my_gam = gam(Cya~s(Age, bs="cr", k=8), data=Cyano_rec, knots=list(Age=x_values), optimMethod="ML", sp=0)
# plot the data
plot(Cyano_rec$Age, Cyano_rec$Cya)
# plot the model
lines(Cyano_rec$Age,predict(my_gam,Cyano_rec))
# calculate the knots and plot them
y_values = predict(my_gam,data.frame(Age=x_values))
points(x_values,y_values,col="red",pch=15)

# fit three models
my_gam1 = gam(Cya~s(Age, bs="cr", k=8), data=Cyano_rec, knots=list(Age=x_values), optimMethod="ML", sp=1)
my_gam2 = gam(Cya~s(Age, bs="cr", k=8), data=Cyano_rec, knots=list(Age=x_values), optimMethod="ML", sp=2)
my_gam5 = gam(Cya~s(Age, bs="cr", k=8), data=Cyano_rec, knots=list(Age=x_values), optimMethod="ML", sp=5)
# plot them all
plot(Cyano_rec$Age, Cyano_rec$Cya)
lines(Cyano_rec$Age,predict(my_gam,Cyano_rec))
lines(Cyano_rec$Age,predict(my_gam1,Cyano_rec),col="blue")
lines(Cyano_rec$Age,predict(my_gam2,Cyano_rec),col="green")
lines(Cyano_rec$Age,predict(my_gam5,Cyano_rec),col="orange")

# auto-select sp
my_gam_auto = gam(Cya~s(Age, bs="cr", k=8), data=Cyano_rec, knots=list(Age=x_values), optimMethod="ML")
# plot all
plot(Cyano_rec$Age, Cyano_rec$Cya)
lines(Cyano_rec$Age,predict(my_gam,Cyano_rec))
lines(Cyano_rec$Age,predict(my_gam1,Cyano_rec),col="blue")
lines(Cyano_rec$Age,predict(my_gam2,Cyano_rec),col="green")
lines(Cyano_rec$Age,predict(my_gam5,Cyano_rec),col="orange")
lines(Cyano_rec$Age,predict(my_gam_auto,Cyano_rec),col="red")
# show chosen value
my_gam_auto$sp

my_gamm = gamm(Cya ~ s(Age, bs="cr", k = 8), data=Cyano_rec, 
               knots=list(Age=x_values), optimMethod="ML", 
               correlation = corCAR1(form = ~ Age))
# print the summary of the gamm
summary(my_gamm)

plot(Cyano_rec$Age, Cyano_rec$Cya)
lines(Cyano_rec$Age,predict(my_gam_auto,Cyano_rec),col="red")
lines(Cyano_rec$Age,predict(my_gamm$gam,Cyano_rec),col="violet")

summary(my_gamm$lme)

acf(resid(my_gamm$lme,type="normalized"))

# do a prediction with standard error
my_prediction = predict.gam(my_gamm$gam,se.fit=TRUE)
summary(my_prediction)

# plot data and model
plot(Cyano_rec$Age, Cyano_rec$Cya)
lines(Cyano_rec$Age, my_prediction$fit, col="violet")

# plot 95% confidence interval
lines(Cyano_rec$Age,my_prediction$fit + 1.96*my_prediction$se.fit,col="violet",lty=2)
lines(Cyano_rec$Age,my_prediction$fit - 1.96*my_prediction$se.fit,col="violet",lty=2)

################################################
## Functions for derivatives of GAM(M) models ##
################################################
Deriv <- function(mod, n = 200, eps = 1e-7, newdata, term) {
    if(inherits(mod, "gamm"))
        mod <- mod$gam
    m.terms <- attr(terms(mod), "term.labels")
    if(missing(newdata)) {
        newD <- sapply(model.frame(mod)[, m.terms, drop = FALSE],
                       function(x) seq(min(x), max(x), length = n))
        names(newD) <- m.terms
    } else {
        newD <- newdata
    }
    newDF <- data.frame(newD) ## needs to be a data frame for predict
    X0 <- predict(mod, newDF, type = "lpmatrix")
    newDF <- newDF + eps
    X1 <- predict(mod, newDF, type = "lpmatrix")
    Xp <- (X1 - X0) / eps
    Xp.r <- NROW(Xp)
    Xp.c <- NCOL(Xp)
    ## dims of bs
    bs.dims <- sapply(mod$smooth, "[[", "bs.dim") - 1
    ## number of smooth terms
    t.labs <- attr(mod$terms, "term.labels")
    ## match the term with the the terms in the model
    if(!missing(term)) {
        want <- grep(term, t.labs)
        if(!identical(length(want), length(term)))
            stop("One or more 'term's not found in model!")
        t.labs <- t.labs[want]
    }
    nt <- length(t.labs)
    ## list to hold the derivatives
    lD <- vector(mode = "list", length = nt)
    names(lD) <- t.labs
    for(i in seq_len(nt)) {
        Xi <- Xp * 0
        want <- grep(t.labs[i], colnames(X1))
        Xi[, want] <- Xp[, want]
        df <- Xi %*% coef(mod)
        df.sd <- rowSums(Xi %*% mod$Vp * Xi)^.5
        lD[[i]] <- list(deriv = df, se.deriv = df.sd)
    }
    class(lD) <- "Deriv"
    lD$gamModel <- mod
    lD$eps <- eps
    lD$eval <- newD - eps
    lD ##return
}
                
# return those points where the derivative is 95% significant                       
signif_deriv = function(my_gamm,term,other_terms=NULL) {
    my_deriv = Deriv(my_gamm)
    deriv_is_significant = abs(my_deriv[[term]]$deriv)>1.96*abs(my_deriv[[term]]$se.deriv)
    x_values = data.frame(V1 = my_deriv$eval)
    colnames(x_values)=term
    if (!is.null(other_terms)) {
        for (other_term in other_terms) {
            x_values[,other_term]=0
        }
    }
    y_values = predict.gam(my_gamm$gam,newdata=x_values,type="terms")[,paste0("s(",term,")")]
    y_values[!deriv_is_significant]=NA
    y_values = y_values + my_gamm$gam$coefficients[1]
    return(data.frame(x=x_values[,term],y=y_values))
}

# calculate these points
significant_derivative_points = signif_deriv(my_gamm,"Age")
# plot points and model estimate
plot(Cyano_rec$Age, Cyano_rec$Cya)
lines(Cyano_rec$Age, my_prediction$fit, col="violet")
lines(Cyano_rec$Age,my_prediction$fit + 1.96*my_prediction$se.fit,col="violet",lty=2)
lines(Cyano_rec$Age,my_prediction$fit - 1.96*my_prediction$se.fit,col="violet",lty=2)
# plot a thicker line (line width = 2) to show where the trend is significant
lines(significant_derivative_points,col="violet",lwd=2)

?gamm

icesdata = read.csv("../Data/sst_by31.csv",sep=";")
head(icesdata)
plot(icesdata)

ices_gamm = gamm(temperature ~ s(decimalyear, bs="cr", k = 8) , data=icesdata, 
                 knots=list(decimalyear=x_values), optimMethod="ML")
plot(icesdata$decimalyear, icesdata$temperature)
lines(icesdata$decimalyear, predict(ices_gamm$gam), col="violet")

# get the year
icesdata$year = floor(icesdata$decimalyear)
# subtract it from decimalyear to get the season
icesdata$season = icesdata$decimalyear - icesdata$year

head(icesdata)

ices_gamm = gamm(temperature ~ s(decimalyear, bs="cr", k = 8) + s(season, bs="cc",k=12), data=icesdata, 
                 knots=list(decimalyear=x_values, season=c(0,1)), optimMethod="ML", 
                 correlation = corCAR1(form = ~ decimalyear|year))
plot(ices_gamm$gam)

ices_gamm$gam$coefficients

# get the intercept - it is the first of the coefficients
intercept = ices_gamm$gam$coefficients[1]
intercept

# predict the terms one by one
my_prediction = predict(ices_gamm$gam,se.fit=TRUE,type="terms")
print(my_prediction)

# get the temperature from the first columm
pred_temperature = intercept + my_prediction$fit[,1]

# get minimum and maximum temperature
pred_temperature_min = intercept + my_prediction$fit[,1] - 1.96*my_prediction$se.fit[,1]
pred_temperature_max = intercept + my_prediction$fit[,1] + 1.96*my_prediction$se.fit[,1]

# do the plot
plot(icesdata$decimalyear, icesdata$temperature)
lines(icesdata$decimalyear, pred_temperature, col="red")
lines(icesdata$decimalyear, pred_temperature_min, lty=2, col="red")
lines(icesdata$decimalyear, pred_temperature_max, lty=2, col="red")


significant_derivative_points = signif_deriv(ices_gamm,term="decimalyear",other_terms = c("season"))
plot(icesdata$decimalyear, icesdata$temperature)
lines(icesdata$decimalyear, pred_temperature, col="red")
lines(icesdata$decimalyear, pred_temperature_min, lty=2, col="red")
lines(icesdata$decimalyear, pred_temperature_max, lty=2, col="red")
lines(significant_derivative_points, lwd=2, col="blue")
