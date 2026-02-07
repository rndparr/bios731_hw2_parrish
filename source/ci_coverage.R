options(stringsAsFactors=FALSE)


# check if true_beta in given CI
covered <- function(ci, true_beta, alpha=0.05) {
	ifelse(true_beta >= ci[[1]] & true_beta <= ci[[2]], 1, 0)
}

# get coverage; takes an lm model or numeric object
get_ci_coverage <- function(z, true_beta, name_str, alpha=0.05) {

	if (class(z) == 'lm') {
		ci <- confint(z, 'x')['x',]
		names(ci) <- gsub(' ', '', names(ci))
	} else {
		ci <- quantile(z, c(alpha/2, 1-(alpha/2)), na.rm=TRUE)
	}

	# get CI coverage
	coverage <- covered(ci, true_beta, alpha=0.05)

	# output data frame with correct column names
	ret <- data.frame(ci[[1]], ci[[2]], coverage)
	colnames(ret) <- paste0(name_str, c('_ci_lb', '_ci_ub', '_coverage'))

	return(ret)
}
