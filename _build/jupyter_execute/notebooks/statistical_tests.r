icesdata = read.csv("../Data/sst_by31.csv",sep=";")
head(icesdata)
plot(icesdata)

# get the year
icesdata$year = floor(icesdata$decimalyear)
# subtract it from decimalyear to get the season
icesdata$season = icesdata$decimalyear - icesdata$year

head(icesdata)

icesdata_july = icesdata[(icesdata$season > 6/12) & (icesdata$season < 7/12),]
plot(icesdata_july$decimalyear, icesdata_july$temperature)

july_means = aggregate(icesdata_july$temperature,by = list(year=icesdata_july$year),FUN=mean)
head(july_means)

july_means = aggregate(icesdata_july$temperature,by = list(year=icesdata_july$year),FUN=mean)
colnames(july_means)[2]="temperature"
head(july_means)
plot(july_means)

period1 = july_means$year < 1980
period2 = july_means$year >= 1980

temperatures1 = july_means$temperature[period1]
temperatures2 = july_means$temperature[period2]

temperatures1
temperatures2

acf(temperatures1)
acf(temperatures2)

?t.test

t.test(x=temperatures1, y=temperatures2, alternative = "less")

?shapiro.test

shapiro.test(temperatures1)
shapiro.test(temperatures2)

hist(temperatures1)

wilcox.test(x=temperatures1, y=temperatures2, alternative = "less")

runif(10)

noise1 = 1e-10*runif(length(temperatures1))
noise2 = 1e-10*runif(length(temperatures2))

wilcox.test(x=temperatures1+noise1, y=temperatures2+noise2, alternative = "less")

?bartlett.test

bartlett.test(list(temperatures1, temperatures2))

sd(temperatures1)
sd(temperatures2)

?fisher.test


