a = 3
b <- 4    # this does the same

a

b

sqrt((a^2)+(b^2))

sentence = "I like hamsters."
truth = TRUE
lie = FALSE

class(sentence)

pi
as.character(pi)

as.numeric(truth)
as.numeric(lie)

ls()

rm(truth)
rm("lie")
rm(list=c("a","b"))

rm(list=ls())

vec1 = c(1,2,3)
print(vec1)

vec2 = rep("abc", 100)
print(vec2)

vec3 = 4:10
print(vec3)

vec4 = seq(from=10, to=20, by=0.1)
print(vec4)

?seq

seq(from = 0, to =100, by= (100/6))

letters = c("a", "b", "c", "d")
letters
rep(letters,each=2)

mynumbers = c(1,4,1,8,2,5,7,1,4)
mynumbers[5]

mynumbers[c(3,4,5)]

mynumbers[1:5]

mynumbers[mynumbers>5]

mynumbers+100

mynumbers^3

sqrt(mynumbers)

nine_numbers = c(0,0,1,1,0,0,1,1,0)
mynumbers * nine_numbers

three_numbers = c(10,100,1000)
mynumbers + three_numbers

two_numbers = c(100,200)
mynumbers + two_numbers

t=seq(from=0, to= 10, by=0.1)
t
myseries=sin(t)
myseries
plot(t,myseries)




participants = data.frame(name       = c("Anna", "Boris", "Christina", "David"),
                          surname    = c("Meier", "Smirnov", "Rabe", "Potter"),
                          age        = c(23, 25, 30, 24),
                          is.student = c(TRUE, TRUE, FALSE, TRUE),
                          stringsAsFactors = FALSE)

participants

print(participants)

participants$age

participants$age[3]

participants$arrived = c(FALSE, TRUE, TRUE, FALSE)
participants

participants$arrived[4]=TRUE
participants

mean(participants$age[participants$arrived == TRUE])

mean(participants$age[participants$arrived == TRUE & participants$is.student == TRUE])
mean(participants$age[participants$arrived & participants$is.student])

participants[4,2]

participants[c(1,4),"surname"]

participants[,"surname"]



getwd()

#setwd("/students_files/jkaiser")   # put in your surname here

sealevel=read.csv2(file = "warnemuende.txt", skip=2, stringsAsFactors = FALSE)

str(sealevel)

sealevel$decimalyear = as.numeric(sealevel$decimalyear)
str(sealevel)

head(sealevel)
summary(sealevel)

plot(sealevel$decimalyear, sealevel$sealevel)



plot(sealevel$decimalyear,sealevel$sealevel, type="l")



hist(sealevel$sealevel)

library()

library(ggplot2)

ggplot(data = sealevel) + geom_path(mapping = aes(x=decimalyear, y=sealevel))

ggplot(data = sealevel) + 
  geom_path(aes(x=decimalyear, y=sealevel)) + 
  geom_smooth(aes(x=decimalyear, y=sealevel), method = "lm") +
  scale_y_continuous(name = "relative sea level (mm)")

png(file="testplot.png", width=1000, height=1000, res=150, units="px")
ggplot(data = sealevel) + 
  geom_path(aes(x=decimalyear, y=sealevel)) + 
  geom_smooth(aes(x=decimalyear, y=sealevel), method = "lm") +
  scale_y_continuous(name = "relative sea level (mm)")
dev.off()

apply(sealevel, 2, mean)   # apply the function "mean" to sealevel over the index 2 (=columns)

apply(sealevel, 2, mean, na.rm=TRUE) # remove the missing values before applying the mean

apply(sealevel, 1, mean, na.rm=TRUE)



sealevel$year = floor(sealevel$decimalyear)
sealevel[1:15,]

sealevel_annual = aggregate(sealevel, by=list(sealevel$year), mean, na.rm=TRUE)
sealevel_annual



write.csv2(sealevel_annual, file="warnemuende_annual.txt", row.names=FALSE)

# setwd("/students_files/feldner")   # put in your surname here
sealevel = read.csv2(file = "warnemuende.txt", skip = 2, stringsAsFactors=FALSE)
sealevel$decimalyear = as.numeric(sealevel$decimalyear)
sealevel$sealevel[sealevel$sealevel==-99999]=NA
head(sealevel)

for (i in 1:10) {
    print(sealevel_annual$sealevel[i])
}

for (i in seq_along(sealevel_annual$sealevel)) {
    print(sealevel_annual$sealevel[i])
}



for (i in 2:length(sealevel_annual$sealevel)) {
    difference = sealevel_annual$sealevel[i] - sealevel_annual$sealevel[i-1]
    difference = round(difference,2)
    print(paste0("In the year ",sealevel_annual$year[i]," we saw a sea level change by ",difference," mm."))
}

for (i in 2:length(sealevel_annual$sealevel)) {
    difference = sealevel_annual$sealevel[i] - sealevel_annual$sealevel[i-1]
    difference = round(difference,2)
    if (difference > 0) {
        print(paste0("In the year ",sealevel_annual$year[i]," we saw a sea level rise: ",difference," mm."))
    } else {
        print(paste0("In the year ",sealevel_annual$year[i]," we saw a sea level drop: ",difference," mm."))
    }
}

df1 = data.frame(a=1, b=2)                 # define data.frame with one row
df2 = data.frame(a=c(2,3,4), b=c(4,6,8))   # define a second data.frame with three rows
rbind(df1,df2)

# initialize with no data
rises=NULL
falls=NULL

# loop over years
for (i in 2:length(sealevel_annual$sealevel)) {
    difference = sealevel_annual$sealevel[i] - sealevel_annual$sealevel[i-1]
    # create data.frame with one row
    my_change = data.frame(from=???, 
                           to=???,
                           change=???)
    # append it to either "rises" or "falls"
    if (difference > 0) {
        rises = ???
    } else {
        falls = ???
    }
}

# show the first rows of the output
print("first 10 rises:")
rises[1:10,]

print("first 10 falls:")
falls[1:10,]



rises = rises[order(rises$change, decreasing = TRUE),]
falls = falls[order(falls$change, decreasing = FALSE),]

largest_rises = rises[1:5,]
largest_falls = falls[1:5,]

print("largest rises:")
largest_rises
print("largest falls:")
largest_falls

calc_power = function(base, exponent) {
    power = base^exponent
    return(power)
}

calc_power(9,2)
calc_power(10,3)

largest_rises = function(timesteps, values, n) {  
    rises = NULL
    
    ???
    
    return(largest_rises)
}

largest_rises(sealevel_annual$year, sealevel_annual$sealevel, 5)



largest_rises = function(timesteps, values, n) {  
    rises = NULL
    
    for (i in 2:length(values)) {
        difference = values[i] - values[i-1]
        # create data.frame with one row
        my_change = data.frame(from=timesteps[i-1], 
                               to=timesteps[i],
                               change=difference)
        # append it to either "rises" or "falls"
        if (is.finite(difference)) {
            if (difference > 0) {
                rises = rbind(rises,my_change)
            }
        }
    }
    
    rises = rises[order(rises$change,decreasing = TRUE),]
    largest_rises = rises[1:n,]
    
    return(largest_rises)
}


