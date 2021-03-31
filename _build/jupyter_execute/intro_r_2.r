# Introduction into R - Part 2
This is part 2/2 of the introduction into R that is given for the Baltic Earth Winter School (BEWS). Feel free to share and distribute it.

## Outline
Part 1 of the introduction teaches some basic functionality of R. 
* Variables and their data types
* Vectors and data.frames
* Reading and writing data (textfiles)
* Loading packages
* Creating simple plots
* Loops and if-clauses
* Writing your own functions
* Using "apply" and "aggregate"

Part 2 of the introduction teaches some R features specific to the analysis of time series and spatial data.
* Data formats for storing time information
* Simple linear models (regression)
* Lists vs Vectors
* Working with NetCDF data (plotting simple maps)
* Basic statistical tests

## 1. Data formats for storing time information

Let us load the monthly sea level data file again which we used in the last exercise. Please enter the correct path.

#setwd("/students_files/feldner")   # put in your surname here
sealevel = read.csv2(file = "warnemuende.txt", skip = 2, stringsAsFactors=FALSE)
sealevel$decimalyear = as.numeric(sealevel$decimalyear)
sealevel$sealevel[sealevel$sealevel==-99999]=NA
head(sealevel)

We have the strange time unit `decimalyear`. We want to convert it to a more suitable time format. The best one is the POSIXct format.

To convert it to the format, we first split the decimalyear into year and day_of_year:

sealevel$year = floor(sealevel$decimalyear)
sealevel$day_of_year = (sealevel$decimalyear - sealevel$year) * 365  # only approximately
head(sealevel)

Now let us first generate a date that is the first day of the year. Later we will add the days.

sealevel$date = paste0(sealevel$year,"-01-01")
head(sealevel)

We convert to POSIXct now. Then we have to add the days as seconds.

sealevel$date = as.POSIXct(sealevel$date)
sealevel$date = sealevel$date + sealevel$day_of_year * 24 * 3600
head(sealevel)

Let's do a plot using "date" as axis rather than decimalyear.

library("ggplot2")

ggplot(data=sealevel) + 
  geom_path(aes(x=date, y=sealevel))

This looks quite similar until we zoom in. Maybe we are interested in two years only.

as.POSIXct("2001-01-01")

c(as.POSIXct("1995-01-01"),as.POSIXct("1997-01-01"))

start = as.POSIXct("1995-01-01")
end   = as.POSIXct("1997-01-01")
ggplot(data=sealevel) + 
  geom_path(aes(x=date, y=sealevel)) + 
  scale_x_datetime(limits=c(start,end))

Another advantage of `POSIXct` is that you can format it in any way you like.

format(sealevel$date[1],"%d.%m.%Y")

 Use the `format()` function to get output in the following formats:

* `Apr 04, 1855`
* `4. April 1855`
* `17/04/1855 11:17 AM`

Hint: Getting help by typing `?format` will not tell you too much. But in the section "Details", it will tell you which specific `format` function exists for your data type. So you need to check out the help for that function.

#?format.POSIXct
format(sealevel$date[1],"%b %m, %Y")
format(sealevel$date[1],"%d. %B %Y")
format(sealevel$date[1],"%d/%m/%Y %I:%M %p")

<span style="color: red;">Task: </span> Use the `format()` function to add a "month" column to our data.frame. Make sure it is numeric.



<span style="color: red;">Task: </span> Plot the sea level data over a monthly time axis of 1 year length.

Hint: You can use the following command to get the x axis nice:

`scale_x_continuous(name = "month", limits=c(1,12), breaks=1:12)`

library(ggplot2)



## 2. Simple linear models

We skip this topic because we will have it in the time series analysis lecture.

## 3. Lists vs Vectors

You can have lists and vectors in R. They are different:

|   | **Vectors**  |  **Lists**  |
|---|---|---|
| elements have | same type  | possibly different type |
| generating  | `v = c(1,2,3)` |  `l = list(1,"abc",TRUE)`   |
| accessing element `i` | `v[i]`  |  `l[[i]]` |
| apply operations or functions  |  yes, directly  |  no, only using `lapply()`  |

When you call some functions, they often return a list, so you should know how to work with them. Let's make an example. We create a histogram.

a = hist(sealevel$sealevel)

If we look at the Variable Inspector, it states that `a` is of type `histogram`. But actually, it's just a list.

is.list(a)

So, we can access its elements. 

<span style="color: red;">Task: </span> Type `a$` and press the TAB key. You can see that you can access its elements by their name.



We can also access them by their index in the list using double square brackets.

a[[2]]

You can create your own lists like this:

mylist = list(text="My list", vector=c(1,2,3))
mylist

And we can easily add elements, by their name or index.

mylist$histogram = a
mylist[[4]]="Element 4"
mylist

Note that the third element, `$histogram`, is also a list. So you can access its values by 

`mylist$histogram$counts`

or by

`mylist[[3]][[2]]`

<span style="color: red;">Bonus Task: </span> In part 1 of this introduction, we defined a function `largest_rises()`. Based on that, write a function `largest_rises_and_falls()` which will calculate both and then return a list with two elements: `rises` and `falls`.



## 4. Working with NetCDF data (plotting a simple map)

NetCDF is a very common file format that allows to store geospatial data. 

Advantages:
* Commonly used
* Self-describing (contains axes, units, ...)
* Searchable (possible to load parts of the file)
* Binary file, compression possible (small file size)
* ...

Disadvantages:
* can only be read/written with the NetCDF library (included in a variety of software).

In R, there are several packages that allow working with NetCDF data. We will use the RNetCDF package.

library("RNetCDF")

NetCDF files are not "loaded" like normal ascii files. Instead we 
* "open" the file
* "inquire" what is inside the file and 
* load what we need.

We choose a file from the German Maritime and Hydrographic Agency (BSH) that contains SST for March of this year.

nc = open.nc("/students_files/data/bsh_sst.nc")
fileinfo = file.inq.nc(nc)
fileinfo

You see we have 3 dimensions and 4 variables. We can again "inquire" what these dimensions and variables are. But they start with 0, not with 1.

print("inquiring dimension 0")
dim.inq.nc(nc,0)
print("inquiring dimension 1")
dim.inq.nc(nc,1)
print("inquiring dimension 2")
dim.inq.nc(nc,2)

print("inquiring variable 0")
var.inq.nc(nc,0)
print("inquiring variable 1")
var.inq.nc(nc,1)
print("inquiring variable 2")
var.inq.nc(nc,2)
print("inquiring variable 3")
var.inq.nc(nc,3)

Let us write a function that makes it easier to check the variables in the file.

list_variables = function(nc) {
    fileinfo = file.inq.nc(nc)
    for (i in 0:(fileinfo$nvars - 1)) {
        varinfo = var.inq.nc(nc,i)
        print(paste0(varinfo$ndims," dim variable:    ",varinfo$name))
        for (j in varinfo$dimids) {
            diminfo = dim.inq.nc(nc,j)
            print(paste0("   ",diminfo$name))
        }
    }
}

list_variables(nc)

We can then see which variable we may want to use. In our case it is mcsst that we want to plot, which depends on longitude, latitude and time. We can load the variable like this:

mcsst = var.get.nc(nc,"mcsst")

`mcsst` is an array. An array is something like a multidimensional matrix. Let us check its dimensions.

dim(mcsst)

It has three dimensions. The last one is the time dimension. Let us plot the first time step.

image(mcsst[,,1])

This looks a bit weird, doesn't it? 

<span style="color: red;">Task: </span> Where can you find Denmark?

Maybe it makes sense to load the longitide and latitude values as well.

<span style="color: red;">Task: </span> Load the longitude and latidude values and save them as `lon` and `lat`.



Now we can try to do a better `image` plot.

image(x=lon, y=lat, z=mcsst[,,1])

Okay that didn't work out but we got a nice error message. 

<span style="color: red;">Task: </span> Use the simple `plot()` function to check which of the axes `lat` or `lon` is not increasingly ordered.



Obviously we have to revert the lat axis. We can use the `rev()` function to reverse a vector.

lat = rev(lat)

But then we also have to reverse the second dimension of the array. We can do it using the `apply()` function. The trick is, always give those indexes that you would **not** want to apply the function to (the axes that you would like to keep).

mcsst = apply(mcsst, c(1,3), rev)

Now we can try again.

image(x=lon, y=lat, z=mcsst[,,1])

Again a nice error message. It tells us we have to flip the dimensions (transpose a matrix). This can be done with the `t()` function.

image(x=lon, y=lat, z=t(mcsst[,,1]))

Wow, our first map! But, as always, we can draw much nicer ones using the `ggplot2` package. But to do so, we first have to create a data.frame like this:

| lon | lat | sst |
|---|---|---|
| -4 | 49 | 0.1 |
| -3 | 49 | 0.2 |
| -2 | 49 | NA |
| ... | ... | ... |

It is easy to start with the `sst` column. We only have to use the `as.vector` function to convert the matrix to a vector.

sst_df = data.frame(sst=as.vector(mcsst[,,1]))

For the longitude and latitude, we have to check which of them changes fastest. I always do that by try and error.

sst_df$lon = rep(lon, length(lat))
sst_df$lat = rep(lat, each=length(lon))

library("ggplot2")

ggplot(data=sst_df) + geom_raster(aes(x=lon,y=lat,fill=sst))

That looks ugly so we have to do it the other way around.

sst_df$lon = rep(lon, each=length(lat))
sst_df$lat = rep(lat, length(lon))
ggplot(data=sst_df) + geom_raster(aes(x=lon,y=lat,fill=sst))

But having a coastline would also be nice. Let us load one from a text file.

coastline = read.csv2("/students_files/data/coastline_baltic.txt", sep="", stringsAsFactors=FALSE)
colnames(coastline) = c("lon", "lat")
coastline$lon=as.numeric(coastline$lon)
coastline$lat=as.numeric(coastline$lat)
head(coastline)

Let's put it into the map.

sst_df$lon = rep(lon, each=length(lat))
sst_df$lat = rep(lat, length(lon))
ggplot(data=sst_df) + 
  geom_raster(aes(x=lon,y=lat,fill=sst)) +
  geom_path(aes(x=lon,y=lat), data=coastline) +
  scale_x_continuous(limits=c(0,31)) +
  scale_y_continuous(limits=c(50,66)) +
  scale_fill_gradientn(colours = c("darkblue","green","yellow","red"), values=c(0,0.3,0.7,1), na.value = "white")

<span style="color: red;">Bonus Task: </span> Create a temporal mean over the 13 days using the `apply()` function (using `mean` with `na.rm=TRUE`) and do a plot of this mean temperature from March 1st to 13th.



We have not yet made use of the **attributes** of the variables in the NetCDF file. They are important because they may contain the unit or a description of what the variable actually is.

Let us look at the result of `var.inq.nc()` for the `time` variable.

var.inq.nc(nc,"time")

There are 4 attributes for this variable. Let's look at the first one:

att.inq.nc(nc,"time",0)
att.get.nc(nc,"time",0)

Again it may make sense to write a small function.

list_attributes = function(nc, varname) {
    varinfo = var.inq.nc(nc, varname)
    print(paste0(varinfo$natts," attributes for variable ",varname,":"))
    for (i in 0:(varinfo$natts - 1)) {
        attinfo = att.inq.nc(nc,varname,i)
        attvalue = att.get.nc(nc,varname,i)
        print(paste0("   ",attinfo$name," = ",attvalue))
    }
}

list_attributes(nc, "time")

<span style="color: red;">Bonus Task: </span> Read the `time` variable. Use the information you see in the `units` attribute to create a time axis in the `POSIXct` format. Then, create a time series plot for `mcsst[185,144,]`



## 5. Basic statistical tests

If you want to do statistical tests, most of them are already implemented in R. The trick is to find out which of your tests is appropriate for your research question. 

Some commonly used tests are explained here:

[ http://r-statistics.co/Statistical-Tests-in-R.html ]

A large overview on statistical tests can be found here:

[ http://www.biostathandbook.com/testchoice.html ]

Let's just create two random time series and do a few statistical tests on them to see how it works.

series1 = runif(100)
series2 = runif(100)
plot(series1)
points(series2, col="red")

t.test(series1, series2, alternative="greater")

<span style="color: red;">Task: </span> Try to extract the p-value and save it in a variable `p`. Hint: use the `is.list()` function to check if the result of `t.test()` is a list.





<span style="color: red;">Task: </span> Go to the following webpage

[ http://www.biostathandbook.com/testchoice.html ]

and find a test to check whether the variance differs between the two vectors. Do this test in R. 

Hint: The functions are typically named like the tests. Type the first letters of the test name and then push the tab key (autocomplete) to see whuch functions are available.

