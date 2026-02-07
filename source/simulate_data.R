

get_sim_data <- function(n, beta_tx, error_dist, ...) {
	error_func <- error_dists[[error_dist]]
	beta_0 <- 1
	x <- rbinom(n, 1, prob = 0.5)
	epsilon <- error_func(n, ...)
	y <- beta_0 + (beta_tx * x) + epsilon

	data.frame(x=x, y=y)
}