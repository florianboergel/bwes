library("WaveletComp");

library("fields");

x = periodic.series(start.period = 50, length = 1000)
x = x + 0.2*rnorm(1000)  # add some noise

plot(x, type="l")

power_spectrum <- function(x)
    {
    x.fft <- fft(x) # ADD HERE
    sym.x <- floor(length(x.fft)/2) # Symetric part of fft
    range <- seq(1, sym.x, 1)
    x.fft <- x.fft[range]
    x.fft.power <- abs(x.fft)**2# ADD HERE
    freq <- 0:(length(x.fft)-1) * 1 / length(x.fft) / 2 
    our.own.power <- list("freq" = freq, "power" = x.fft.power)
    return(our.own.power)
}

a <- power_spectrum(x)
plot(1/a$freq,a$power,xlim=c(0,100), type = "l")

x.spec <- spec.pgram(x,plot = FALSE)
plot(1/x.spec$freq, x.spec$spec, type = "l", xlim = c(0,100))

x1 <- periodic.series(start.period = 90, length = 500)
x2 <- 1.2*periodic.series(start.period = 40, length = 500)
x <- c(x1, x2) + 0.3*rnorm(1000)

y1 <- periodic.series(start.period = 90, length = 1000)
y2 <- 1.2*periodic.series(start.period = 40, length = 1000)
y <- (y1 + y2)/2  + 0.3*rnorm(1000)

par(mfrow=c(2,1))    # set the plotting area into a 2*1 array

plot(x, type = "l")
plot(y, type = "l")

x.spec <- spec.pgram(x, plot = FALSE)
y.spec <- spec.pgram(y, plot = FALSE)

par(mfrow=c(1,2))    # set the plotting area into a 2*1 array

# xlim setzen
plot(1/y.spec$freq, y.spec$spec, type = "l", xlim=c(0, 200))
plot(1/x.spec$freq, x.spec$spec, type = "l", xlim=c(0, 200))

my.data <- data.frame(x = x)
my.w.x <- analyze.wavelet(my.data, "x",loess.span = 0,
                        dt = 1, dj = 1/250,lowerPeriod = 16,
                        upperPeriod = 128,make.pval = TRUE, n.sim = 10)


my.data <- data.frame(x = y)
my.w.y <- analyze.wavelet(my.data, "x",loess.span = 0,
                        dt = 1, dj = 1/250,lowerPeriod = 16,
                        upperPeriod = 128,make.pval = TRUE, n.sim = 10)

wt.image(my.w.x, n.levels = 100,legend.params = list(lab = "wavelet power levels"))

wt.image(my.w.y, n.levels = 100,legend.params = list(lab = "wavelet power levels"))

x = periodic.series(start.period = 1, end.period = 100, length = 1000)
x = x + 0.2*rnorm(1000)
plot(x, type="l")

my.data <- data.frame(x = x)
my.w <- analyze.wavelet(my.data, "x",loess.span = 0,dt = 1, dj = 1/250,make.pval = TRUE, n.sim = 10)
wt.image(my.w, n.levels = 250,legend.params = list(lab = "wavelet power levels"))

morlet_wavelet <- function(t){
return(pi**-0.25 * exp(1i*6*t) * exp(-0.5*t**2))
}

t <- seq(-6,6,0.01)

plot(Re(morlet_wavelet(t)), col="black",xlab="", ylab="", type="l")
par(new=TRUE)
lines(Im(morlet_wavelet(t)), col="green",xlab="", ylab="", lty="solid")
title("The Morlet mother wavelet")
legend("topright",legend=c("Real","Imag"), col = c("black", "green"),
       pch=rep(c(16,18),each=4),ncol=2,cex=0.7,pt.cex=0.7)

morlet_wavelet <- function(t){
    return(pi**-0.25 * exp(1i*6*t) * exp(-0.5*t**2))
}

morlet_wavelet_fft <- function(f){
    wave <- (pi**-0.25) * exp(-0.5 * (f - 6)**2) 
    return(wave)
}

x = periodic.series(start.period = 1, end.period = 100, length = 1000)
x = x + 0.2*rnorm(1000)

f <- fft(x)# ADD HERE

dt = 1
dj = 1/12
s0 = 2

n <- NROW(x)

# FFT frequencies
freq <- 0:(length(f)-1) * 1 / length(f) * 2 * pi

# Scaling of the wavelet 
J1 <- round(log2(n * dt / s0) / dj)
scale <- s0 * 2 ^ ((0:J1) * dj)
wave <- matrix(0, nrow = J1 + 1, ncol = n)

for (a1 in seq_len(J1 + 1)) {
psi.star = Conj(morlet_wavelet_fft(scale[a1] * freq))
psi.ft.bar = ((scale[a1] * n)^0.5)* psi.star
wave[a1, ] <- fft(f * psi.ft.bar, inverse = TRUE)
}

power <- abs(wave)^2

new.data <- aperm(power, c(2,1))

range <- seq(1, length(f), 1)

image.plot(range, scale, new.data, ylim=c(16,128))

sst <- read.table("http://paos.colorado.edu/research/wavelets/wave_idl/nino3sst.txt", header = F, skip = 19)

date <- seq(ISOdate(1871,1,1), ISOdate(1996,12,1), by = "quarter")

my.data <- data.frame(x = sst, date = date)
plot(date, my.data$V1, type = "l", ylab="[°C]", main = "NINO3 SST")

my.w <- analyze.wavelet(my.data, "V1",loess.span = 0,dt = 0.25, dj = 1/250,make.pval = TRUE, n.sim = 30)
wt.image(my.w,color.key="i", n.levels = 250,legend.params = list(lab = "wavelet power levels"))

data(weather.radiation.Mannheim)
head(weather.radiation.Mannheim)

par(mfrow=c(3,1))

date <- as.POSIXct(strptime(weather.radiation.Mannheim$date, format="%Y-%m-%d"))

plot(date, weather.radiation.Mannheim$temperature,
     ylab = "Temp in Degree C", type="l")
plot(date, weather.radiation.Mannheim$humidity,
     type="l", ylab = "relative humidity [%]")
plot(date, weather.radiation.Mannheim$radiation,
     type="l", ylab ="radiation ( µ SV / h)")

do.wavelet <- function(x, col.name){
    my.w <- analyze.wavelet(x,
                            col.name,
                            loess.span = 0,
                            dt = 1,
                            dj = 1/50,
                            make.pval = TRUE,
                            n.sim = 30)
    
    max.power <- max(my.w$Power)
    wt.image(my.w,
             color.key ="i",
             maximum.level = sqrt(max.power) * 1.001,
             exponent = 0.5,
             n.levels = 250,
             legend.params = list(lab = "wavelet power levels"),
             show.date = TRUE, date.format= "%F", timelab = "")
}

# wavelet for temperature

do.wavelet(weather.radiation.Mannheim, "temperature")

# wavelet for radiation

do.wavelet(weather.radiation.Mannheim, "radiation")

my.wc <- analyze.coherency(weather.radiation.Mannheim,
my.pair = c("temperature", "humidity"),
loess.span = 0,
dt = 1, dj = 1/50,
lowerPeriod = 32, upperPeriod = 1024,
make.pval = TRUE, n.sim = 10)

wc.image(my.wc, n.levels = 250,
legend.params = list(lab = "cross-wavelet power levels"),
color.key = "interval",
# time axis:
label.time.axis = TRUE, show.date = TRUE,
spec.time.axis = list(at = paste(2005:2014, "-01-01", sep = ""),
labels = 2005:2014),
timetcl = -0.5, # outward ticks
# period axis:
periodlab = "period (days)",
spec.period.axis = list(at = c(32, 64, 128, 365, 1024)),
periodtck = 1, periodtcl = NULL)
