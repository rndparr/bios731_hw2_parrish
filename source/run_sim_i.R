
# Rscript run_sim_i.R ${i} ${ncores}


# parse arguments
args=(commandArgs(TRUE))
cat(paste0('\nargs:\n'))
print(args)
cat()
if(length(args)==0) {
	stop("Error: No arguments supplied!")
} else  {
	i = as.integer(args[[1]])
	ncores = as.integer(args[[2]])
}


###############################################################
## LOAD LIBRARIES, SET UP PARALLELIZATION
###############################################################

# set up parallelization
library(doFuture)
library(doRNG)
library(foreach)


registerDoFuture()
if (ncores > 1){
	pln <- plan(multicore, workers=ncores)
	cat(paste0('Starting job with ', ncores, ' cores\n'))
} else {
	plan(sequential)
}


###############################################################
## define or source functions used in code below
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

n_sim <- 475
B <- 500
B_inner <- 100

## testing:
# n_sim <- 20; B <- 10; B_inner <- 5;

# i=1; j=1

n_sample_vals <- c(10, 50, 500)
true_beta_tx_vals <- c(0, 0.5, 2)
error_dists <- setNames(
	c(normal_errors, heavy_tailed_errors), 
	c('normal', 'heavy-tailed'))

# simulation scenarios
params <- expand.grid(
	n_sim = 475, 
	n = n_sample_vals,
	beta_tx = true_beta_tx_vals,
	error_dist = names(error_dists)
)


###############################################################
# RUN SIMULATIONS
###############################################################


# initial seed to generate other seeds
set.seed(02072026)
seed <- sample(1:10000, n_sim, replace=FALSE)


# loop over scenarios
# for (i in 1:nrow(params)) {
print('Job parameters:')
print(params[i,])
print(paste0('B=', B, '; B_inner=', B_inner, '; alpha=', alpha))
print(paste0('scenario ', i))

out_log <- here::here('logs', paste0('scenario_', i, 'tasks.txt'))
# foreach combine n_sims for scenario i
scenario_i_output <- foreach(j=1:n_sim, .combine=rbind) %dorng% {
	# message every time start 25th sim
	# if( (j %% 5) == 0 ) { cat(paste0('j=', j, '\n'), file=out_log, append=TRUE) }
	cat(paste0(j, '\n'), file=out_log, append=TRUE)
	set.seed(seed[j])

	sim_data <- do.call(get_sim_data, params[i,])

	wald_time <- func_time(
		estimates <- get_wald_estimates(sim_data, true_beta=params[i, 'beta_tx'], alpha=alpha)
	)

	boot_time <- func_time(
		boot_estimates <- get_bootstrap_estimates(sim_data, 
			beta_hat=estimates[['beta_hat']], 
			true_beta=params[i, 'beta_tx'],
			B=B, B_inner=B_inner, alpha=alpha)
	)

	bootp_time <- boot_time - boot_estimates[['boott_time']]

	res_j <- cbind('scenario'=i, params[i,], B, B_inner, alpha, estimates, boot_estimates, bootp_time, wald_time, boot_time, 'seed'=seed[j])
} 

# save data
scenario_i_path <- here::here('data', paste0('scenario_', i, '.Rds'))
save(scenario_i_output, file=scenario_i_path)

print('All done!')

# }



# # merge data for all scenarios
# big_data <- data.frame()
# for (i in 1:nrow(params)) {
# 	scenario_i_path <- here::here('data', paste0('scenario_', i, '.Rds'))
# 	load(scenario_i_path)

# 	big_data <- rbind(big_data, scenario_i_output)

# }

# bleh <- foreach(j=1:n_sim, .combine=rbind) %dorng% {
# 	set.seed(seed[j])

# 	sim_data <- do.call(get_sim_data, params[i,])

# 	wald_time <- func_time(
# 		estimates <- get_wald_estimates(sim_data, true_beta=params[i, 'beta_tx'], alpha=alpha)
# 	)

# 	boot_time <- func_time(
# 		boot_estimates <- get_bootstrap_estimates(sim_data, 
# 			beta_hat=estimates[['beta_hat']], 
# 			true_beta=params[i, 'beta_tx'],
# 			B=B, B_inner=B_inner, alpha=alpha)
# 	)

# 	res_j <- cbind(params[i,], estimates, boot_estimates, wald_time, boot_time, 'seed'=seed[j])
# } 



