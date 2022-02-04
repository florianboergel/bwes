#setwd("/students_files/feldner")   # put in your surname here
sealevel = read.csv2(file = "warnemuende.txt", skip = 2, stringsAsFactors=FALSE)
sealevel$decimalyear = as.numeric(sealevel$decimalyear)
sealevel$sealevel[sealevel$sealevel==-99999]=NA
head(sealevel)

sealevel$year = floor(sealevel$decimalyear)
sealevel$day_of_year = (sealevel$decimalyear - sealevel$year) * 365  # only approximately
head(sealevel)

sealevel$date = paste0(sealevel$year,"-01-01")
head(sealevel)

sealevel$date = as.POSIXct(sealevel$date)
sealevel$date = sealevel$date + sealevel$day_of_year * 24 * 3600
head(sealevel)

library("ggplot2")

ggplot(data=sealevel) + 
  geom_path(aes(x=date, y=sealevel))

as.POSIXct("2001-01-01")

c(as.POSIXct("1995-01-01"),as.POSIXct("1997-01-01"))

start = as.POSIXct("1995-01-01")
end   = as.POSIXct("1997-01-01")
ggplot(data=sealevel) + 
  geom_path(aes(x=date, y=sealevel)) + 
  scale_x_datetime(limits=c(start,end))

format(sealevel$date[1],"%d.%m.%Y")

#?format.POSIXct
format(sealevel$date[1],"%b %m, %Y")
format(sealevel$date[1],"%d. %B %Y")
format(sealevel$date[1],"%d/%m/%Y %I:%M %p")



library(ggplot2)



a = hist(sealevel$sealevel)

is.list(a)



a[[2]]

mylist = list(text="My list", vector=c(1,2,3))
mylist

mylist$histogram = a
mylist[[4]]="Element 4"
mylist



library("RNetCDF")

nc = open.nc("/students_files/data/bsh_sst.nc")
fileinfo = file.inq.nc(nc)
fileinfo

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

mcsst = var.get.nc(nc,"mcsst")

dim(mcsst)

image(mcsst[,,1])



image(x=lon, y=lat, z=mcsst[,,1])



lat = rev(lat)

mcsst = apply(mcsst, c(1,3), rev)

image(x=lon, y=lat, z=mcsst[,,1])

image(x=lon, y=lat, z=t(mcsst[,,1]))

sst_df = data.frame(sst=as.vector(mcsst[,,1]))

sst_df$lon = rep(lon, length(lat))
sst_df$lat = rep(lat, each=length(lon))

library("ggplot2")

ggplot(data=sst_df) + geom_raster(aes(x=lon,y=lat,fill=sst))

sst_df$lon = rep(lon, each=length(lat))
sst_df$lat = rep(lat, length(lon))
ggplot(data=sst_df) + geom_raster(aes(x=lon,y=lat,fill=sst))

coastline = read.csv2("/students_files/data/coastline_baltic.txt", sep="", stringsAsFactors=FALSE)
colnames(coastline) = c("lon", "lat")
coastline$lon=as.numeric(coastline$lon)
coastline$lat=as.numeric(coastline$lat)
head(coastline)

sst_df$lon = rep(lon, each=length(lat))
sst_df$lat = rep(lat, length(lon))
ggplot(data=sst_df) + 
  geom_raster(aes(x=lon,y=lat,fill=sst)) +
  geom_path(aes(x=lon,y=lat), data=coastline) +
  scale_x_continuous(limits=c(0,31)) +
  scale_y_continuous(limits=c(50,66)) +
  scale_fill_gradientn(colours = c("darkblue","green","yellow","red"), values=c(0,0.3,0.7,1), na.value = "white")



var.inq.nc(nc,"time")

att.inq.nc(nc,"time",0)
att.get.nc(nc,"time",0)

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



series1 = runif(100)
series2 = runif(100)
plot(series1)
points(series2, col="red")

t.test(series1, series2, alternative="greater")






