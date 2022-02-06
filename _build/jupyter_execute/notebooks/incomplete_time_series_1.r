# read in Swinoujsce data
sldata = read.csv("../Data/sealevel/swinoujscie.rlrdata",sep = ";",header=FALSE)
# select first two columns only
sldata = sldata[,1:2]
colnames(sldata) = c("year","swinoujscie")
# set negative values to missing values
sldata$swinoujscie[sldata$swinoujscie<0]=NA
# plot the data
plot(sldata, type="l") 

# select 20th century only
sldata = sldata[(sldata$year>=1900) & (sldata$year<2000),]
# remove the temporal mean
sldata$swinoujscie = sldata$swinoujscie - mean(sldata$swinoujscie,na.rm=TRUE)
# try fft
spectrum = fft(sldata$swinoujscie)
print(spectrum[1:10])

sldata_filled = sldata
sldata_filled$swinoujscie[is.na(sldata_filled$swinoujscie)] = 0
spectrum_filled = fft(sldata_filled$swinoujscie)
plot(abs(spectrum_filled)^2, type="l",col="red")

iaa = function(signal, steps=10) {
  # get length of time series
  M = length(signal)
  # check where data are present
  signal_present = is.finite(signal)
  N = sum(signal_present)
  # calculate times where data are present, assuming T=1
  times = (seq_len(M)-1)/M
  times = times[signal_present]
  values = signal[signal_present]
  # calculate Nyquist frequency 2*pi/T but T=1
  omega1 = 2*pi
  # for each frequency M, define a fourier vector based on the times
  a = matrix(0,nrow=N,ncol=M)
  for (j in seq_len(M)) {
    a[,j]=exp(1i*(j-1)*omega1*times)
  }
  # initialize R matrix with identity matrix
  R = diag(1,N)
  beta = rep(0,M)
  # now do the iteration loop
  for (i in seq_len(steps)) {
    print(paste0("iaa ",i,"/",steps))
    # calculate beta
    tempvec = solve(R,values)
    numerator = apply(Conj(a)*tempvec,2,sum)
    tempvec = solve(R,a)
    for (j in seq_len(M)) {
      denominator = sum(Conj(a[,j])*tempvec[,j])
      beta[j] = numerator[j]/denominator
    }
    # calculate R
    R = diag(0,N)
    for (j in seq_len(M)) {
      R = R + abs(beta[j])^2*a[,j]%*%t(Conj(a[,j]))
    }
  }
  return(beta*M)
}

print("calculating ...")
spectrum = iaa(sldata$swinoujscie,steps = 5)
print("done.")

plot(abs(spectrum)^2, type="l")
lines(abs(spectrum_filled)^2, col="red")

# reconstruct the spectrum
N=length(spectrum)
reconstruction = fft(spectrum,inverse=TRUE)/N
reconstruction = Re(reconstruction)
# plot the result and the original data
plot(sldata$year,reconstruction,col="green",type="l")
lines(%%%%%%%%%%,sldata$swinoujscie)

stations = c("swinoujscie","copenhagen","helsinki","stockholm","warnemuende")
# initialise a matrix with NA values
sl_matrix = matrix(NA,12*100,length(stations))
# loop over the stations
for (i in seq_along(stations)) {
    # read in the tide gauge data
    stationdata = read.csv(paste0("../Data/sealevel/",stations[i],".rlrdata"),sep = ";",header=FALSE)
    # select first two columns only
    stationdata = stationdata[,1:2]
    colnames(stationdata) = c("year","sealevel")
    # set negative values to missing values
    stationdata$sealevel[stationdata$sealevel <(-500)]=NA
    # select 20th century only
    stationdata = stationdata[(stationdata$year>=1900)&(stationdata$year<2000),]
    # remove the mean
    stationdata$sealevel = stationdata$sealevel - mean(stationdata$sealevel,na.rm=TRUE)
    # put the data into the matrix
    sl_matrix[,i] = stationdata$sealevel
}
# plot the data as a matrix
image(x=stationdata$year,y=seq_along(stations),z=sl_matrix)
# write station names to the right
axis(4,at = 1:5,labels=toupper(substr(stations,1,3)))


dineof <- function(Xo, n.max=NULL, ref.pos=NULL, delta.rms=1e-5, method="svd", speed=1, replace_ref=TRUE, punish_large_guesses=0){
  
  if(is.null(n.max)){
    n.max=dim(Xo)[2]
  }	
  
  na.true <- which(is.na(Xo))
  na.false <- which(!is.na(Xo))
  if(is.null(ref.pos)) ref.pos <- sample(na.false, max(30, 0.01*length(na.false)))
  
  Xa <- replace(Xo, na.true, 0)
  if (replace_ref) {Xa <- replace(Xa, ref.pos, 0)}
  rms.prev <- Inf
  rms.now <- sqrt(mean(Xo[ref.pos]^2))
  n.eof <- 1
  RMS <- rms.now
  NEOF <- n.eof
  Xa.best <- Xa
  n.eof.best <- n.eof	
  while(rms.prev - rms.now > delta.rms & n.max > n.eof){ #loop for increasing number of EOFs
    while((rms.prev - rms.now > delta.rms)){ #loop for EOF refinement
      rms.prev <- rms.now
      if(method == "irlba"){
        SVDi <- irlba::irlba(Xa, nu=n.eof, nv=n.eof)	  
      }
      if(method == "svd"){
        SVDi <- svd(Xa)	  
      }
      if(method == "svds"){
        SVDi <- RSpectra::svds(Xa, k=n.eof)	  
      }
      RECi <- as.matrix(SVDi$u[,seq(n.eof)]) %*% as.matrix(diag(SVDi$d[seq(n.eof)], n.eof, n.eof)) %*% t(as.matrix(SVDi$v[,seq(n.eof)]))
      Xa[na.true] <- RECi[na.true]*speed+Xa[na.true]*(1-speed)
      if (replace_ref) {
        Xa[ref.pos] <- RECi[ref.pos]*speed+Xa[ref.pos]*(1-speed)
      }
      rms.now <- sqrt(mean(c((RECi[ref.pos] - Xo[ref.pos])^2,punish_large_guesses*RECi[na.true]^2)))
      print(paste(n.eof, "EOF", "; RMS =", round(rms.now, 8)))
      RMS <- c(RMS, rms.now)
      NEOF <- c(NEOF, n.eof)
      gc()
      if(rms.now == min(RMS)) {
        Xa.best <- Xa
        n.eof.best <- n.eof
      }
    }
    # Add EOF and check for improvement
    n.eof <- n.eof + 1
    rms.prev <- rms.now
    if(method == "irlba"){
      SVDi <- irlba::irlba(Xa, nu=n.eof, nv=n.eof)	  
    }
    if(method == "svd"){
      SVDi <- svd(Xa)	  
    }
    if(method == "svds"){
      SVDi <- RSpectra::svds(Xa, k=n.eof)	  
    }
    RECi <- as.matrix(SVDi$u[,seq(n.eof)]) %*% as.matrix(diag(SVDi$d[seq(n.eof)], n.eof, n.eof)) %*% t(as.matrix(SVDi$v[,seq(n.eof)]))
    Xa[na.true] <- RECi[na.true]*speed+Xa[na.true]*(1-speed)
    if (replace_ref) {
      Xa[ref.pos] <- RECi[ref.pos]*speed+Xa[ref.pos]*(1-speed)
    }
    rms.now <- sqrt(mean(c((RECi[ref.pos] - Xo[ref.pos])^2,punish_large_guesses*RECi[na.true]^2)))
    print(paste(n.eof, "EOF", "; RMS =", round(rms.now, 8)))
    RMS <- c(RMS, rms.now)
    NEOF <- c(NEOF, n.eof)
    gc()
    if(rms.now == min(RMS)) {
      Xa.best <- Xa
      n.eof.best <- n.eof
    }
  }
  
  Xa <- Xa.best
  n.eof <- n.eof.best
  rm(list=c("Xa.best", "n.eof.best", "SVDi", "RECi"))
  
  Xa[ref.pos] <- Xo[ref.pos]
  
  RESULT <- list(
    Xa=Xa, n.eof=n.eof, RMS=RMS, NEOF=NEOF, ref.pos=ref.pos
  )
  
  RESULT
}

reconstruction = dineof(sl_matrix, n.max = 3)

image(x=stationdata$year,y=seq_along(stations),z=reconstruction$Xa)
axis(4,at = 1:5,labels=toupper(substr(stations,1,3)))

# plot reconstruction by first three EOFs in blue
plot(sldata$year,reconstruction$Xa[,1],type="l",col="blue",xlim=c(1940,1960))
# plot original data in black
lines(sldata$year,sldata$swinoujscie,col="black")
# get root mean squared error after last iteration
rms = reconstruction$RMS[length(reconstruction$RMS)]
# get locations of missing values
missing = is.na(sldata$swinoujscie)
# calculate upper range
upper_range = sldata$swinoujscie*NA
upper_range[missing]=reconstruction$Xa[missing,1]+1.96*rms
# calculate lower range
lower_range = sldata$swinoujscie*NA
lower_range[missing]=reconstruction$Xa[missing,1]-1.96*rms
# plot these
lines(sldata$year,upper_range,col="lightblue")
lines(sldata$year,lower_range,col="lightblue")
