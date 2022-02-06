sums_of_n_dices = c(10,12)

results = 1:6
probabilities = rep(1/6,6)
plot(results, probabilities)

n=2
results = (n*1):(n*6)     # possible results go from 2 to 12

# first calculate the number of possibilities to get a certain sum
possibilities = results*0
for (dice1 in 1:6) {
    for (dice2 in 1:6) {
        sum=dice1+dice2
        possibilities[results==sum]=possibilities[results==sum]+1
    }
}

# then calculate probability by dividing through the total number of combinations
probabilities = possibilities / sum(possibilities)

# do the plot
plot(results,probabilities)

match(c("c","d"),c("a","b","c","d"))

# find out the indexes in the probability vector
indexes = match(sums_of_n_dices,results) 
print("indexes in probability vector:")
print(indexes)

# find out the individual probabilities for the single sums
ind_probs = probabilities[indexes]
print("probabilities of individual sums:")
print(ind_probs)

# find out the overall probability:
overall_prob = prod(ind_probs)
print("overall probability:")
print(overall_prob)

calc_probability = function(n) {
    if (n==1) {
        # one dice only - return a very simple data.frame
        df = data.frame(results=1:6, probabilities=rep(1/6,6))
        return(df)
    } else {
        # first, get the probabilities for sums of n-1 dices
        old_probabilities = calc_probability(n-1)$probabilities
        # the new results are easy to calculate
        new_results = (n*1):(n*6)
        l = length(new_results)
        # initialise new probabilities with zero
        new_probabilities = new_results*0
        # the new probabilities emerge from the old ones depending on the value of the current dice
        new_probabilities[1:(l-5)] = new_probabilities[1:(l-5)] + 1/6 * old_probabilities # 1/6 chance that new dice == 1
        new_probabilities[2:(l-4)] = new_probabilities[2:(l-4)] + 1/6 * old_probabilities # 1/6 chance that new dice == 2
        new_probabilities[3:(l-3)] = new_probabilities[3:(l-3)] + 1/6 * old_probabilities # 1/6 chance that new dice == 3
        new_probabilities[4:(l-2)] = new_probabilities[4:(l-2)] + 1/6 * old_probabilities # 1/6 chance that new dice == 4
        new_probabilities[5:(l-1)] = new_probabilities[5:(l-1)] + 1/6 * old_probabilities # 1/6 chance that new dice == 5
        new_probabilities[6:l    ] = new_probabilities[6:l    ] + 1/6 * old_probabilities # 1/6 chance that new dice == 6
        df = data.frame(results=new_results, probabilities=new_probabilities)
        return(df)
    } 
}
plot(calc_probability(5))

likelihood = function(n) {
    # calculate probability density
    df = calc_probability(n)
    
    # check if all individual sums are possible 
    if (all(sums_of_n_dices %in% df$results)) {
        indexes = match(sums_of_n_dices,df$results) 
        ind_probs = df$probabilities[indexes]
        overall_prob = prod(ind_probs)
        return(overall_prob)
    } else { # there was a sum which is not possible with n dices
        return(0)
    }
}

my_likelihood = rep(NA,5)

for (n in 1:5) {
    my_likelihood[n]=likelihood(n)
}
plot(my_likelihood)

ml_estimate = which(my_likelihood == max(my_likelihood))
print(paste0("Maximum likelihood estimate: n = ",ml_estimate))

possible = which(my_likelihood >= 0.05*max(my_likelihood))
print(paste0("Possible n value after likelihood ratio test: n = ",possible))

possible_likelihoods = my_likelihood[possible]
df = data.frame(n=possible,p=possible_likelihoods)
df = df[rev(order(df$p)),]
print(df)

sums_of_n_dices = c(12,10,8,7,3)
my_likelihood = rep(NA,5)

for (n in seq_along(my_likelihood)) {
    my_likelihood[n]=likelihood(n)
}

ml_estimate = which(my_likelihood == max(my_likelihood))
print(paste0("Maximum likelihood estimate: n = ",ml_estimate))
possible = which(my_likelihood >= 0.05*max(my_likelihood))
print(paste0("Possible n value after likelihood ratio test: n = ",possible))
plot(my_likelihood)

prior_probabilities = c(1/7, 1/7, 3/6, 1/7, 1/7)
plot(prior_probabilities,ylim=c(0,0.5))

sums_of_n_dices = c(7,10)

my_likelihood = rep(NA,5)

for (n in seq_along(my_likelihood)) {
    my_likelihood[n]=likelihood(n)
}

ml_estimate = which(my_likelihood == max(my_likelihood))
print(paste0("Maximum likelihood estimate: n = ",ml_estimate))
possible = which(my_likelihood >= 0.05*max(my_likelihood))
print(paste0("Possible n value after likelihood ratio test: n = ",possible))
plot(my_likelihood)

posterior_probabilities = prior_probabilities * my_likelihood
posterior_probabilities = posterior_probabilities/sum(posterior_probabilities) # normalise to a sum of 1
plot(posterior_probabilities)


