library("RNetCDF")
nc = open.nc("../Data/HadISST_Baltic.nc")
sst = var.get.nc(nc,"TEMPERATURE")
lon = var.get.nc(nc,"LONGITUDE")
lat = var.get.nc(nc,"LATITUDE")
time = var.get.nc(nc,"TIME")
close.nc(nc)

dim(sst)

library(fields)
image.plot(lon,lat,sst[,,1])

nc = open.nc("../Data/HadISST_Baltic.nc")
timeunits = att.get.nc(nc,"TIME","units")
close.nc(nc)
timeunits

date = as.POSIXct(time*24*3600,origin="1870-01-01",tz="GMT")

my_matrix = matrix(NA,nrow=length(lon)*length(lat),ncol=length(time))
dim(my_matrix)

my_matrix[,] = sst[,,]
image(y=date,z=my_matrix)

water_points = is.finite(sst[,,1])
water_points

# we select only water rows
reduced_matrix = my_matrix[water_points,]
dim(my_matrix)
dim(reduced_matrix)

eof = svd(reduced_matrix)
summary(eof)

explained_signal = eof$d^2 / sum(eof$d^2)
explained_signal[1:5]
plot(explained_signal[1:5])

plot(date,eof$v[,1]*eof$d[1],type="l")

eof1 = matrix(NA,length(lon),length(lat))
eof1[water_points] = eof$u[,1]
image.plot(lon,lat,eof1)

image.plot(lon,lat,-eof1)
plot(date,-eof$v[,1]*eof$d[1],type="l")
# zoom in to first three years
plot(date[1:36],-eof$v[1:36,1]*eof$d[1],type="l")

eof2 = matrix(NA,length(lon),length(lat))
eof2[water_points] = eof$u[,2]
image.plot(lon,lat,eof2)
plot(date,eof$v[,2]*eof$d[2],type="l")
# zoom in to first three years
plot(date[1:36],eof$v[1:36,2]*eof$d[2],type="l")

scale=max(abs(eof1),na.rm=TRUE)
image.plot(lon,lat,-eof1/scale)
plot(date,-eof$v[,1]*eof$d[1]*scale,type="l")
# zoom in to first three years
plot(date[1:36],-eof$v[1:36,1]*eof$d[1]*scale,type="l")

scale=max(abs(eof2),na.rm=TRUE)
image.plot(lon,lat,eof2/scale)
plot(date,eof$v[,2]*eof$d[2]*scale,type="l")
# zoom in to first three years
plot(date[1:36],eof$v[1:36,2]*eof$d[2]*scale,type="l")

eof = svd(reduced_matrix-mean(reduced_matrix))
summary(eof)

explained_variance = eof$d^2 / sum(eof$d^2)
explained_variance[1:5]

eof1 = matrix(NA,length(lon),length(lat))
eof1[water_points] = eof$u[,1]
scale=max(abs(eof1),na.rm=TRUE)
image.plot(lon,lat,-eof1/scale)
plot(date,-eof$v[,1]*eof$d[1]*scale,type="l")
# zoom in to first three years
plot(date[1:36],-eof$v[1:36,1]*eof$d[1]*scale,type="l")

eof2 = matrix(NA,length(lon),length(lat))
eof2[water_points] = eof$u[,2]
scale=max(abs(eof2),na.rm=TRUE)
image.plot(lon,lat,-eof2/scale)
plot(date,-eof$v[,2]*eof$d[2]*scale,type="l")
# zoom in to first three years
plot(date[1:36],-eof$v[1:36,2]*eof$d[2]*scale,type="l")
