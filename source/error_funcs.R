
normal_errors <- function(n_sample, mu=0, sigma2=2, ...) { 
	return(rnorm(n_sample, mu, sqrt(sigma2)))
}

heavy_tailed_errors <- function(n_sample, v=3, ...) {
	u <- rt(n_sample, df=v)
	return(u * sqrt(2 * ((v - 2) / v)))
}

