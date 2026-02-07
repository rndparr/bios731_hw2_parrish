
## function to fit linear model with y ~ x
# WARNING: can produce NA coefficient estimates
fit_model <- function(sim_data){
  lm(y ~ x, data = sim_data)
}

# wald estimates
get_wald_estimates <- function(sim_data, true_beta, alpha=0.05) {
	# fit model
	model_lm <- fit_model(sim_data)

	# coef, se, coverage
	out <- as.data.frame(rbind(coef(summary(model_lm))['x', c('Estimate', 'Std. Error')]))
	colnames(out) <- c('beta_hat', 'se')
	out <- cbind(out, get_ci_coverage(model_lm, true_beta, 'wald', alpha))

	return(out)
}

# get a bootstrap sample
get_boot_sample <- function(sim_data) {
	n <- nrow(sim_data)
	samp_ind <- sample(1:n, size=n, replace=TRUE)
	sim_data_star <- sim_data[samp_ind, ]
	row.names(sim_data_star) <- NULL

	return(sim_data_star)
}

# get t_star
bootstrap_t_inner <- function(sim_data_b, boot_beta, beta_hat, B_inner) {
	## INNER LOOP - Bootstrap t
	# boot_beta_b <- rep(NA, B_inner)
	# for (k in 1:B_inner) {
	# 	sim_data_bk <- get_boot_sample(sim_data_b)
	# 	model_lm_k <- fit_model(sim_data_bk)
	# 	boot_beta_b[k] <- coef(model_lm_k)[['x']]
	# }
	boot_beta_b <- foreach(k=1:B_inner, .combine=c) %dorng% {
			sim_data_bk <- get_boot_sample(sim_data_b)
			model_lm_k <- fit_model(sim_data_bk)
			coef(model_lm_k)[['x']]	
	}	
	# calculate tstar
	se_star <- sd(boot_beta_b, na.rm=TRUE)
	t_star <- (boot_beta - beta_hat) / se_star

	return(t_star)
}


# get both boot_p and boot_t estimates
get_bootstrap_estimates <- function(sim_data, beta_hat, true_beta, B=10, B_inner=5, alpha=0.05) {

	## OUTER LOOP - Bootstrap P, t
	seeds <- floor(runif(B, 1, 10000))

	boot_beta <- t_star <- boott_time <- rep(NA, B)
	for (b in 1:B) {
		set.seed(seeds[b])
		sim_data_b <- get_boot_sample(sim_data)
		model_lm <- fit_model(sim_data_b)
		boot_beta[b] <- coef(model_lm)[['x']]

		# ## INNER LOOP - Bootstrap t
		boott_time[b] <- func_time(t_star[b] <- bootstrap_t_inner(sim_data_b, boot_beta[b], beta_hat, B_inner))
	}

	# Bootstrap P results
	bootp_ci_coverage <- get_ci_coverage(boot_beta, true_beta, 'bootp', alpha)
	boot_beta_hat <- mean(boot_beta, na.rm=TRUE)
	bootp_se <- sd(boot_beta, na.rm=TRUE) / sqrt(length(boot_beta))


	# Bootstrap t results
	t_quants <- quantile(t_star, probs=c(1-(alpha/2), alpha/2), na.rm=TRUE)
	se_boot_beta <- sd(boot_beta, na.rm=TRUE)
	boott_ci <- beta_hat - t_quants * se_boot_beta
	boott_coverage <- covered(boott_ci, true_beta, alpha)

	ret <- data.frame(boot_beta_hat, bootp_se, bootp_ci_coverage, 
		'boott_ci_lb'=boott_ci[[1]], 'boott_ci_ub'=boott_ci[[2]], 
		boott_coverage, 'boott_time'=sum(boott_time))

	return(ret)
}

