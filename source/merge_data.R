
# merge data for all scenarios
dat <- data.frame()
for (i in 1:18) {
	scenario_i_path <- here::here('data', paste0('scenario_', i, '.Rds'))
	load(scenario_i_path)

	# add j column for later plotting
	scenario_i_output$j <- 1:nrow(scenario_i_output)
	scenario_i_output <- scenario_i_output[, c('scenario', 'j', colnames(scenario_i_output)[2:26])]

	dat <- rbind(dat, scenario_i_output)
}


for (col in paste0(c('wald', 'bootp', 'boott'), '_coverage')) {
	dat[, col] <- as.logical(dat[, col])
}


dat$boot_beta_hat_bias <- dat$boot_beta_hat - dat$beta_tx
dat$beta_hat_bias <- dat$beta_hat - dat$beta_tx


all_data_path <- here::here('data', 'all_data.Rds')
save(dat, file=all_data_path)