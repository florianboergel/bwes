# Introduction into R - Part 1
This is part 1/2 of the introduction into R that is given for the Baltic Earth Winter School (BEWS). Feel free to share and distribute it.

## Outline
Part 1 of the introduction teaches some basic functionality of R. 
* Variables and their data types
* Vectors and data.frames
* Reading and writing data (textfiles)
* Creating simple plots
* Using "apply" and "aggregate"
* Loops and if-clauses
* Writing your own functions

Part 2 of the introduction teaches some R features specific to the analysis of time series and spatial data.
* Data formats for storing time information
* Simple linear models (regression)
* Lists vs Vectors
* Working with NetCDF data
* Plotting simple maps
* Basic statistical tests

## 1. Variables and their data types

Variables will be created in R just by assigning them a value. There are two operators for this: `=` and `<-` which represents an arrow to the left.

a = 3
b <- 4    # this does the same

<span style="color: red;">Task: </span> Access the values of a and b by just typing them. Alternatively, use the `print()` function to access their value

a

b

<img src="https://i0.wp.com/pythagoras.nu/wp-content/uploads/2019/03/pythagoras-theorem.png?resize=480%2C352&ssl=1" width=200>
<span style="color: red;">Task: </span> a and b are the shorter sides of a right-angled triangle. Calculate the longer side c using the `sqrt()` function.

sqrt((a^2)+(b^2))

To see which variables are defined, do a right-click to a code cell and click "open vaiable inspector". You can click at the tab of the variable inspector and move it to the very right of your screen, so it will show up in a separate column.

You see that a and b are of type "numeric". Let's see if we can create some other types.

sentence = "I like hamsters."
truth = TRUE
lie = FALSE

We can use the `class()` function to check which data type a variable has.

class(sentence)

We can convert variables to other types by using functions starting with `as.`

pi
as.character(pi)

as.numeric(truth)
as.numeric(lie)

We can use the `ls()` function to see which variables exist.

ls()

We can use the `rm()` function to delete a variable (we can pass the variable, its name, or a list of names).

rm(truth)
rm("lie")
rm(list=c("a","b"))

<span style="color: red;">Task: </span> Delete all existing variables using a single command.

rm(list=ls())

## 2. Vectors, lists and data.frames

### 2.1 Vectors

If you have several values, it makes sense to store them in a vector. The default option to create a vector is using the `c()` function:

vec1 = c(1,2,3)
print(vec1)

But there are several ways of creating a vector. You can for example repeat something, or create a sequence.

vec2 = rep("abc", 100)
print(vec2)

vec3 = 4:10
print(vec3)

vec4 = seq(from=10, to=20, by=0.1)
print(vec4)

How do you know which arguments to pass to a function, e.g. the `seq()` function? You can find that out in two ways.

(a) After writing `seq(` you can press the TAB key to see which arguments are possible.
(b) Type a question mark in front of the function name (`?seq`) to show help on that function.

?seq

<span style="color: red;">Task: </span> Use the `seq()` function to create a sequence from 0 to 100 that has 7 elements.

seq(from = 0, to =100, by= (100/6))

<span style="color: red;">Task: </span> Create a vector that contains the letters 

"a", "b", "c", "d". 

Use the `rep()` function to transform it into 

"a", "a", "b", "b", "c", "c", "d", "d".

letters = c("a", "b", "c", "d")
letters
rep(letters,each=2)

We can access elements of vectors using square brackets.

mynumbers = c(1,4,1,8,2,5,7,1,4)
mynumbers[5]

We can not only use one index but also a vector of indexes.

mynumbers[c(3,4,5)]

This makes sense for showing the first few elements, or for selecting elements that fulfill a specific condition.

mynumbers[1:5]

mynumbers[mynumbers>5]

We can calculate with vectors as we would do with numbers. The operations will be performed element by element. (This is in contrast to Matlab!)

mynumbers+100

mynumbers^3

sqrt(mynumbers)

We can also use two vectors of the same length for calculations.

nine_numbers = c(0,0,1,1,0,0,1,1,0)
mynumbers * nine_numbers

But adding different length also works - which **can make life very difficult!**

three_numbers = c(10,100,1000)
mynumbers + three_numbers

**R just repeats the shorter vector to get the required length!** (You may not like that.) At least it gives a warning if it really doesn't match.

two_numbers = c(100,200)
mynumbers + two_numbers

<span style="color: red;">Task: </span> Create a time axis `t` as a vector from 0 to 10 with a time step of 0.1. Then create a time series `myseries` using the `sin()` function. Use the command `plot(t,myseries)` to plot it.

<span style="color: red;">Bonus Task: </span> Create a series that has a period length of 5, so we have exactly two periods.

t=seq(from=0, to= 10, by=0.1)
t
myseries=sin(t)
myseries
plot(t,myseries)


<span style="color: red;">Bonus Task: </span> Define a vector n from 1 to 10 and calculate

$$\frac{1}{\sqrt{5}} \left( \left( \frac{1+\sqrt{5} }{2} \right)^n - \left( \frac{1-\sqrt{5}}{2} \right)^n \right)$$

What numbers do you get?



### 2.2 data.frames

A data.frame is a very common data structure for storing data in R: A table of several vectors of the same length. 

Each row is a different object. Each column is a different property. Let us create an example.

participants = data.frame(name       = c("Anna", "Boris", "Christina", "David"),
                          surname    = c("Meier", "Smirnov", "Rabe", "Potter"),
                          age        = c(23, 25, 30, 24),
                          is.student = c(TRUE, TRUE, FALSE, TRUE),
                          stringsAsFactors = FALSE)

(We will talk about stringsAsFactors later.)

Now print the data.frame:

participants

print(participants)

There are a lot of ways to access data in a data.frame. For example, we can address the columns by their name using the dollar symbol. This gives us vectors.

participants$age

participants$age[3]

We can add new columns by just providing data. 

participants$arrived = c(FALSE, TRUE, TRUE, FALSE)
participants

<span style="color: red;">Task: </span> David Potter showed up a bit later. Change the data accordingy.

participants$arrived[4]=TRUE
participants

Let us calculate the mean age of all participants that have arrived.

mean(participants$age[participants$arrived == TRUE])

<span style="color: red;">Task: </span> Calculate the mean age of all students that have arrived. You can connect logical expressions using `&` as the AND operator.

mean(participants$age[participants$arrived == TRUE & participants$is.student == TRUE])
mean(participants$age[participants$arrived & participants$is.student])

Another option is to access the data by row and column.

participants[4,2]

Again you can use the names instead of the indexes. Leaving an index empty means "select all".

participants[c(1,4),"surname"]

participants[,"surname"]

<span style="color: red;">Task: </span> Get name, surname and age of all students only.

<span style="color: red;">Bonus Task: </span> Find out what the function `order()` does and sort the list by their age.



## 3. Reading and writing data (textfiles)

Now we would like to work on a real dataset. Let us take a sea level dataset that was downloaded from the Permanent Service for Mean Sea Level webpage (https://www.psmsl.org). But before we can start doing so, we must ensure that we are working in the correct folder.

The following command prints the folder we are working in:<span style="color: red;">Task: </span> Open the file warnemuende.txt and see how the file is structured. Read it in by using the function `read.csv2(...)` and find out which arguments to pass to the function so it reads the file correctly.

getwd()

If this is not your personal folder, change it by putting the correct directory name here:

#setwd("/students_files/jkaiser")   # put in your surname here

<span style="color: red;">Task: </span> Open the file warnemuende.txt and see how the file is structured. Read it in by using the function `sealevel = read.csv2(...)` and find out which arguments to pass to the function so it reads the file correctly. Always use the `stringsAsFactors=FALSE` argument unless you know what you are doing and need to speed up the calculations.

sealevel=read.csv2(file = "warnemuende.txt", skip=2, stringsAsFactors = FALSE)

After loading it is good to check whether all data have the format we expect.

str(sealevel)

We see that sealevel, missingdays and attentionflag are integer values. But decimalyear is character. We need to convert it to numeric.

sealevel$decimalyear = as.numeric(sealevel$decimalyear)
str(sealevel)

There are two functions to quickly see what is inside a data.frame. 

head(sealevel)
summary(sealevel)

<span style="color: red;">Task: </span> Find out what might be wrong with the data!

But it is mostly good to also do a plot and we may see more.

## 4. Creating simple plots

There are two typical ways to do plots in R: 

(a) Using the basic functions 

(b) Using the more fancy `ggplot2` package. 

We will show both possibilities. Let us start with the first one.

plot(sealevel$decimalyear, sealevel$sealevel)

Okay we have a missing value obviously, and it has no attention flag! That's bad. 

<span style="color: red;">Task: </span> Change the bad value to `NA` which is the R expression for missing data!



Okay that is nice but we may prefer a line so we see more.

plot(sealevel$decimalyear,sealevel$sealevel, type="l")

<span style="color: red;">Task: </span> Change the x axis description to "year" and the y axis description to "relative sea level (mm)"



Another nice basic plotting function:

hist(sealevel$sealevel)

For more fancy options it makes sense to use the `ggplot2` package.

You can install packages to R that include functionality. Mostly this is very simple by typing 

`install.packages("my_desired_package")`

but please do not do this here on the server. We have a lot of packages already installed:

library()

Let us load the graphics package `ggplot2`.

library(ggplot2)

The philosophy is to define a plot that is based on a data.frame, and then "add" elements to it.
So our simple plot looks like this:

ggplot(data = sealevel) + geom_path(mapping = aes(x=decimalyear, y=sealevel))

The function `aes()` maps the column names in the data.frame (decimalyear, sealevel) to the input parameters of the plot element, in this case `geom_path`.

We can add a trendline and modify the y axis:

ggplot(data = sealevel) + 
  geom_path(aes(x=decimalyear, y=sealevel)) + 
  geom_smooth(aes(x=decimalyear, y=sealevel), method = "lm") +
  scale_y_continuous(name = "relative sea level (mm)")

And let's save the plot to a png file.

png(file="testplot.png", width=1000, height=1000, res=150, units="px")
ggplot(data = sealevel) + 
  geom_path(aes(x=decimalyear, y=sealevel)) + 
  geom_smooth(aes(x=decimalyear, y=sealevel), method = "lm") +
  scale_y_continuous(name = "relative sea level (mm)")
dev.off()

## 5. Using `apply()` and `aggregate()`

Next, we want to aggregate the monthly data to annual data. The `decimalyear` column means that e.g. 1900.0 is January 1st, 1900 and 1900.5 would be in the middle of the year 1900. Let us first try what the `apply()` function does:

apply(sealevel, 2, mean)   # apply the function "mean" to sealevel over the index 2 (=columns)

apply(sealevel, 2, mean, na.rm=TRUE) # remove the missing values before applying the mean

Note that the last arguments (from argument 4 on) are passed to the function that is called for every column, in this case, `mean()`. 

We could also calculate a mean over the rows, but it makes no sense:

apply(sealevel, 1, mean, na.rm=TRUE)

<span style="color: red;">Task: </span> Use the function `quantile` inside `apply()` to calculate the 5th, 50th and 95th percentile of each column of our data.frame



Another nice function is `aggregate()`, it can also be applied to a whole data.frame. We will use it to calculate annnual means from the monthly means. To do so, we first have to get the calendar year from the decimal year by rounding it downward:

sealevel$year = floor(sealevel$decimalyear)
sealevel[1:15,]

Now we can use `aggregate` to apply a function (in this case the `mean` function) over those entries where `year` is equal.

sealevel_annual = aggregate(sealevel, by=list(sealevel$year), mean, na.rm=TRUE)
sealevel_annual

<span style="color: red;">Task: </span> Use the `ggplot` function to plot the annual time series.



We can use the function `write.csv2()` to export the data to a file:

write.csv2(sealevel_annual, file="warnemuende_annual.txt", row.names=FALSE)

## 6. Loops and if-clauses

# setwd("/students_files/feldner")   # put in your surname here
sealevel = read.csv2(file = "warnemuende.txt", skip = 2, stringsAsFactors=FALSE)
sealevel$decimalyear = as.numeric(sealevel$decimalyear)
sealevel$sealevel[sealevel$sealevel==-99999]=NA
head(sealevel)

In some years there are rises in the sea level, in some years there are drops compared to the year before. Assume your task is to find the 5 years with the largest rise and the 5 years with the largest drop. One way to solve the problem is using a loop.

There are more elegant ways of solving the problem. Typically you should avoid loops in R, since they make the calculations slow.

<span style="color: red;">Bonus Task: </span> While we solve the problem with a loop, write a solution without a loop!

Loops in R work like this:

for (i in 1:10) {
    print(sealevel_annual$sealevel[i])
}

If you want to loop over an entire vector, use the `seq_along()` function:

for (i in seq_along(sealevel_annual$sealevel)) {
    print(sealevel_annual$sealevel[i])
}

<span style="color: red;">Task: </span> Print the sea differences between a year and the previous one. You can use the `length()` function to get the number of elements in a vector.



Let's put more info into the output. We can use the function `paste0()` to connect strings:

`paste0("abc", "def") == "abcdef"`

Let's make the loop more nice:

for (i in 2:length(sealevel_annual$sealevel)) {
    difference = sealevel_annual$sealevel[i] - sealevel_annual$sealevel[i-1]
    difference = round(difference,2)
    print(paste0("In the year ",sealevel_annual$year[i]," we saw a sea level change by ",difference," mm."))
}

Let's explitly write whether we saw a rise of drop.

for (i in 2:length(sealevel_annual$sealevel)) {
    difference = sealevel_annual$sealevel[i] - sealevel_annual$sealevel[i-1]
    difference = round(difference,2)
    if (difference > 0) {
        print(paste0("In the year ",sealevel_annual$year[i]," we saw a sea level rise: ",difference," mm."))
    } else {
        print(paste0("In the year ",sealevel_annual$year[i]," we saw a sea level drop: ",difference," mm."))
    }
}

Now let us create a table of rises and drops like this:

| from | to | change |
|---|---|---|
|1900|1901|33.1|
|1901|1902|10.2|

To do so, we start with two empty data.frames `rises` and `drops`.
Every year we add a line to one of the data.frames, depending in whether the sea level rose or fell.
We use the function `rbind()` to merge two data.frames by their rows. Let us first check how `rbind()` works.

df1 = data.frame(a=1, b=2)                 # define data.frame with one row
df2 = data.frame(a=c(2,3,4), b=c(4,6,8))   # define a second data.frame with three rows
rbind(df1,df2)

Okay so let's do it. We start with `NULL` (no data) in the data.frames `rises` and `falls`.

<span style="color: red;">Task: </span> Complete the code so it will create our list of rises and falls.

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



Now all we need to do is sort the rises and falls and choose the 5 largest ones.

rises = rises[order(rises$change, decreasing = TRUE),]
falls = falls[order(falls$change, decreasing = FALSE),]

largest_rises = rises[1:5,]
largest_falls = falls[1:5,]

print("largest rises:")
largest_rises
print("largest falls:")
largest_falls

## 7. Writing your own functions

Writing functions is very important for speeding up your work. It avoids that you do things twice and reduces errors.

Writing functions in R works like this:

calc_power = function(base, exponent) {
    power = base^exponent
    return(power)
}

You can then invoke functions several times:

calc_power(9,2)
calc_power(10,3)

Please repeat the largest-rise calculations using a function: 

(1) Write a function that calculates the n largest rises in a time series. 

(2) Apply this function to the annual data.

<span style="color: red;">Task: </span> Complete the following code accordingly. You can copy code from above. But make sure you replace the original variables by the arguments of the function, so your function should not contain anything called "sealevel". (Because it should work on any time series.)

largest_rises = function(timesteps, values, n) {  
    rises = NULL
    
    ???
    
    return(largest_rises)
}

largest_rises(sealevel_annual$year, sealevel_annual$sealevel, 5)



The function will not work if missing values occur. We make it ignore possible missing values by checking `is.finite(difference)`.

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

<span style="color: red;">Task: </span> Calculate the 10 largest rises in the monthly sea level data.

