# Statistical tests in R

For most statistical tests, there are already functions implemented in R. The trick is then only to know which test to use.

Some commonly used tests are explained here:

[ http://r-statistics.co/Statistical-Tests-in-R.html ]

A large overview on statistical tests can be found here:

[ http://www.biostathandbook.com/testchoice.html ]

### Example: July SST at station BY31 (Landsort Deep)

Let us read in the ICES dataset we already used for fitting the GAMM.

icesdata = read.csv("../Data/sst_by31.csv",sep=";")
head(icesdata)
plot(icesdata)

Again we define a season:

# get the year
icesdata$year = floor(icesdata$decimalyear)
# subtract it from decimalyear to get the season
icesdata$season = icesdata$decimalyear - icesdata$year

head(icesdata)

For simplicity we assume that "July" means $6/12 < season < 7/12$. Let's extract all July values then.

icesdata_july = icesdata[(icesdata$season > 6/12) & (icesdata$season < 7/12),]
plot(icesdata_july$decimalyear, icesdata_july$temperature)

For some July's, there seem to be several measurements. Let us calculate averages from them.

july_means = aggregate(icesdata_july$temperature,by = list(year=icesdata_july$year),FUN=mean)
head(july_means)

july_means = aggregate(icesdata_july$temperature,by = list(year=icesdata_july$year),FUN=mean)
colnames(july_means)[2]="temperature"
head(july_means)
plot(july_means)

#### Can we say that July mean temperature was different before and after 1980?

period1 = july_means$year < 1980
period2 = july_means$year >= 1980

temperatures1 = july_means$temperature[period1]
temperatures2 = july_means$temperature[period2]

temperatures1
temperatures2

Let's first check for autocorrelation.

acf(temperatures1)
acf(temperatures2)

Well, that's fine. No significant autocorrelation.

So we look at the first table to find out which test we need.

[ http://r-statistics.co/Statistical-Tests-in-R.html ]

?t.test

t.test(x=temperatures1, y=temperatures2, alternative = "less")

But is the test valid? Are the values normally distributed? We find out that a Shapiro test may tell us.

?shapiro.test

shapiro.test(temperatures1)
shapiro.test(temperatures2)

Well, the data passed this test. But this does not guarantee they are actually normally distributed. So let's go for the more general test as well.

hist(temperatures1)

wilcox.test(x=temperatures1, y=temperatures2, alternative = "less")

This didn't work out. We have to make the values unique by adding some noise.

runif(10)

noise1 = 1e-10*runif(length(temperatures1))
noise2 = 1e-10*runif(length(temperatures2))

wilcox.test(x=temperatures1+noise1, y=temperatures2+noise2, alternative = "less")

Yes, both tests told us that July temperatures were significantly higher after 1980 than before.

#### Can we find out whether July temperature variability has changed after 1980?

We look at the advanced table:

[ http://www.biostathandbook.com/testchoice.html ]

and find out that it is the Bartlett's test we need.

?bartlett.test

bartlett.test(list(temperatures1, temperatures2))

sd(temperatures1)
sd(temperatures2)

?fisher.test

fisher.test(temperatures1,temperatures2)

So we see no significant change in variance between the two periods before and after 1980.