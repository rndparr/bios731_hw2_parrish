

###############################################################
## PARSE ARGUMENTS
###############################################################
# Rscript run_sim_i.R ${i} ${ncores}

# parse arguments
args=(commandArgs(TRUE))
cat(paste0('\nargs:\n'))
print(args)
cat()
if(length(args)==0) {
	stop('Error: No arguments supplied!')
} else  {
	i <- as.integer(args[[1]])
	ncores <- as.integer(args[[2]])
}


###############################################################
## LOAD LIBRARIES, SET UP PARALLELIZATION
###############################################################
# libraries
library(doFuture)
library(doRNG)
library(foreach)

# set up parallel environment
registerDoFuture()
if (ncores > 1){
	pln <- plan(multicore, workers=ncores)
	cat(paste0('Starting job with ', ncores, ' cores\n'))
} else {
	plan(sequential)
}


###############################################################
## SOURCE FUNCTIONS
###############################################################
source(here::here('source', 'utility.R'))
source(here::here('source', 'simulate_data.R'))
source(here::here('source', 'ci_coverage.R'))
source(here::here('source', 'models.R'))
source(here::here('source', 'error_funcs.R'))


###############################################################
# PARAMETERS
###############################################################

alpha <- 0.05

# job parameters
n_sim <- 475
B <- 500
B_inner <- 100

## testing:
# n_sim <- 20; B <- 10; B_inner <- 5;
# i=1; j=1

# scenario parameters
n_sample_vals <- c(10, 50, 500)
true_beta_tx_vals <- c(0, 0.5, 2)
error_dists <- setNames(
	c(normal_errors, heavy_tailed_errors), 
	c('normal', 'heavy-tailed'))

# simulation scenarios
sim_params <- expand.grid(
	n_sim = 475, 
	n = n_sample_vals,
	beta_tx = true_beta_tx_vals,
	error_dist = names(error_dists)
)


###############################################################
# LOGGING
###############################################################

# print job parameter info to file
print('Job parameters:')
print(sim_params[i,])
print(paste0('B=', B, '; B_inner=', B_inner, '; alpha=', alpha))
cat(paste0('scenario ', i, '\n'))

# # print session info to file
sI <- sessionInfo()
print(sI)
cat()

# create log for keeping track of j sims for running jobs
out_log <- here::here('logs', paste0('scenario_', i, '_tasks.txt'))

cat(paste0('\nout_log: ', out_log))

###############################################################
# RUN SIMULATIONS
###############################################################

# initial seed to generate other seeds
sim_i_seed <- as.integer(02072026 + i)
set.seed(sim_i_seed)

seed <- sample(1:10000, n_sim, replace=FALSE)

# foreach combine n_sims for scenario i
scenario_i_output <- foreach(j=1:n_sim, .combine=rbind, .errorhandling='remove') %dorng% {

	# output j to file
	cat(paste0(j, '\n'), file=out_log, append=TRUE)

	# set seed
	set.seed(seed[j])


	# generate simulation data
	sim_data <- do.call(get_sim_data, sim_params[i,])

	# get wald estimates, time
	wald_time <- func_time(
		estimates <- get_wald_estimates(sim_data, true_beta=sim_params[i, 'beta_tx'], alpha=alpha)
	)

	# get bootstrap estimates, time
	boot_time <- func_time(
		boot_estimates <- get_bootstrap_estimates(sim_data, 
			beta_hat=estimates[['beta_hat']], 
			true_beta=sim_params[i, 'beta_tx'],
			B=B, B_inner=B_inner, alpha=alpha)
	)

	# get bootp time by subtracting boott_time from total boot_time
	bootp_time <- boot_time - boot_estimates[['boott_time']]


	res_j <- cbind('scenario'=i, sim_params[i,], B, B_inner, alpha, estimates, boot_estimates, bootp_time, wald_time, boot_time, 'seed'=seed[j])
}

# save all data for scenario i
scenario_i_path <- here::here('data', paste0('scenario_', i, '.Rds'))
save(scenario_i_output, file=scenario_i_path)


print('All done!')


