


###############################################################
# PARAMETERS
###############################################################

n_sim <- 475
alpha <- 0.05

B <- 500
B_inner <- 100

n_sample_vals <- c(10, 50, 500)
true_beta_tx_vals <- c(0, 0.5, 2)
error_dists <- c('normal', 'heavy-tailed')

# simulation scenarios
sim_params <- expand.grid(
	n = n_sample_vals,
	beta_tx = true_beta_tx_vals,
	error_dist = error_dists
)
sim_params$scenario <- 1:18

###############################################################



## BIAS TABLE
bias_table <- merge(sim_params, 
	aggregate(
		cbind(beta_hat_bias, boot_beta_hat_bias) ~ scenario, 
		data=dat,  FUN='mean'), 
	by='scenario')
colnames(bias_table) <- c('Scenario', 'n', '$\\beta_{tx}$', 'Error Distribution', 'Bias($\\hat{\\beta}$)', 'Bias($\\hat{\\beta}_{boot}$)')
# bias_header <- c()

## COVERAGE TABLE
coverage_prop <- function(x){
	sum(x) / n_sim
}

coverage_table <- coverage_tab <- merge(sim_params,
	aggregate(
			cbind(wald_coverage, bootp_coverage, boott_coverage) ~ scenario, 
			data=dat,  FUN='coverage_prop'), 
	by='scenario')
colnames(coverage_table) <- c('Scenario', 'n', '$\\beta_{tx}$', 'Error Distribution', 'Wald CI', 'Boot p CI', 'Bootstrap-$t$ CI')
coverage_header <- c(' ' = 4, 'Proportion of 95% CIs containing $\\\\beta_{tx}$' = 3)


## COMP TIME TABLE
time_table <- merge(sim_params,
	aggregate(
			cbind(wald_time, bootp_time, boott_time) ~ scenario, 
			data=dat,  FUN='mean'), 
	by='scenario')
colnames(time_table) <- c('Scenario', 'n', '$\\beta_{tx}$', 'Error Distribution', 'Wald', 'Bootstrap p', 'Bootstrap-$t$')
time_header <- c(' ' = 4, 'Average Time (sec)' = 3)


