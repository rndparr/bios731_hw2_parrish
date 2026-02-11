
# library(ggplot2)
# library(ggplotify) # as_ggplot()
# library(ggh4x) # facet_nested_wrap()
# library(grid)
# library(gtable)



# set plot theme to use for all plots
plot_theme <- theme_bw() + 
	theme(legend.position='bottom',
		legend.margin=margin(0, 0, 0, 0))
theme_set(plot_theme)



# vectors for forming plot titles
model_names <- c(
	'wald'='Wald', 
	'bootp'='Bootstrap p', 
	'boott'=bquote('Bootstrap-'*italic(t)))
labeller_names <- c('wald'='Wald', 
	'bootp'='Bootstrap~p', 
	'boott'="'Bootstrap-'*italic(t)")


###############################################################
# MELT DATA FOR PLOTTING
###############################################################
# inital melt for bias data
# bias_mdat <- reshape2::melt(dat, measure.vars=c('boot_beta_hat_bias', 'beta_hat_bias'), variable.name='bias_model', value.name='bias')
# bias_mdat$bias_model <- factor(bias_mdat$bias_model, levels=c('beta_hat_bias', 'boot_beta_hat_bias'), labels=c(bquote))

models <- c('wald', 'bootp', 'boott')
suffixes <- c('ci_lb', 'ci_ub', 'coverage', 'time')

# other_cols <- c('scenario', 'j', 'n_sim', 'n', 'beta_tx', 
# 	'error_dist', 'B', 'B_inner', 'alpha', 'beta_hat','se',
# 	'boot_beta_hat', 'bootp_se', 'boot_time', 'bias_model', 'bias', 'seed')


# mdat <- data.frame()
# for (model in models) {
# 	model_cols <- paste0(model, '_', suffixes)
# 	mdat_model <- mdat_1[, c(other_cols,  model_cols)]
# 	colnames(mdat_model) <- c(other_cols, suffixes)
# 	mdat_model$model <- model
# 	mdat <- rbind(mdat, mdat_model)
# }

# data for bias plot
bias_mdat <- reshape2::melt(dat, measure.vars=c('boot_beta_hat_bias', 'beta_hat_bias'), variable.name='bias_model', value.name='bias')
bias_mdat$bias_model <- factor(bias_mdat$bias_model, 
	levels=c('beta_hat_bias', 'boot_beta_hat_bias'))

other_cols <- c('scenario', 'j', 'n_sim', 'n', 'beta_tx', 
	'error_dist', 'B', 'B_inner', 'alpha', 'beta_hat','se',
	'boot_beta_hat', 'bootp_se', 'boot_time', 'seed')

mdat <- data.frame()
for (model in models) {
	model_cols <- paste0(model, '_', suffixes)
	mdat_model <- dat[, c(other_cols,  model_cols)]
	colnames(mdat_model) <- c(other_cols, suffixes)
	mdat_model$model <- model
	mdat <- rbind(mdat, mdat_model)
}
mdat$model <- factor(mdat$model, levels=c('wald', 'bootp', 'boott'))


# CI width
mdat$ci_width <- mdat$ci_ub - mdat$ci_lb

# reorder factors so Wald model is first
mdat2 <- mdat
mdat2$model <- factor(mdat$model, levels=c('wald', 'bootp', 'boott'), labels=labeller_names)




###############################################################
# GENERAL PLOTTING FUNCTIONS
###############################################################


# function to add labels to facets of a ggplot
facet_labs <- function(p, rlab=NULL, tlab=NULL){
	gt <- ggplotGrob(p)

	if (!is.null(rlab)){
		strip <-c(subset(gt$layout, grepl('strip-r', gt$layout$name), select=t:r))
		gt <- gtable_add_cols(gt, unit(1, 'lines'), max(strip$r))
		gt <- gtable_add_grob(gt, 
		  textGrob(rlab, rot=-90, gp=gpar(cex=0.9)),  t=min(strip$t), l=max(strip$r)+1, b=max(strip$b))
	}

	if (!is.null(tlab)){
		strip <-c(subset(gt$layout, grepl('strip-t', gt$layout$name), select=t:r))
		gt <- gtable_add_rows(gt, unit(1, 'lines'), max(strip$t)-1)
		gt <- gtable_add_grob(gt, 
			textGrob(tlab, rot=0, gp=gpar(cex=0.9)), t=max(strip$t), l=min(strip$l), r=max(strip$r), b=max(strip$b))
	}

	return(as.ggplot(gt))
}


###############################################################
# FUNCTIONS TO GENERATE SPECIFIC PLOTS
###############################################################


## BIAS PLOT
bias_plot <- function(scales='fixed', ylim=NULL, ...){

	p <- ggplot(bias_mdat, 
			aes(y=bias, x=bias_model, color=bias_model)) + 
		geom_boxplot() +
		stat_summary(fun=mean, geom='point', 
			position=position_dodge(.9), 
			size=2.5, shape=18) +
		geom_text(aes(x=-Inf, y=Inf, label=scenario),
			size=5, color='black',hjust=-0.5, vjust=1.5)

	if(!is.null(ylim)){
		p <- p + lims(y=ylim)
	} 

	p <- p +	
		scale_color_manual(name='',
			labels=c(
				bquote(hat(beta)), bquote({hat(beta)}[p])
				# bquote('Bias('*hat(beta)*')'), bquote('Bias('*{hat(beta)}[p]*')')
			),
			breaks=c('beta_hat_bias', 'boot_beta_hat_bias'),
			values=c('#F8766D', '#00BFC4')) +
		labs(
			title=bquote('Bias of '*{hat(beta)}*' and '*{hat(beta)}[p]*' for all scenarios'),
			x=NULL,
			y=bquote('Bias('*{}%.%{}*')')) + 
		theme(
			axis.text.x = element_blank(),
			axis.ticks.x = element_blank(),
			axis.title.x = element_text(color='white'),
			legend.text=element_text(size=12)) + 
		facet_nested(error_dist + beta_tx ~ n, 
			scales=scales)

	p <- facet_labs(p, bquote('Error Distribution; '*beta['tx']), 'n')

	return(p)
}



# COVERAGE PLOT - not used
coverage_plot <- function(){

	pdat <- reshape2::melt(coverage_tab, measure.vars=c('wald_coverage', 'bootp_coverage', 'boott_coverage'), value.name='coverage', variable.name='model')
	pdat$not_covered <- 1-pdat$coverage
	pdat$model <- gsub('_coverage', '', pdat$model)
	pdat$model <- factor(pdat$model, levels=c('wald', 'bootp', 'boott'))

	p <- ggplot(pdat, 
		aes(model, coverage,
			fill=model)) + 
		geom_bar(stat='identity', width=0.5) +
		geom_hline(yintercept=1-alpha, linetype='dashed', size=0.5) +
		geom_text(aes(x=-Inf, y=Inf, label=scenario),
			size=5, color='black',hjust=-0.5, vjust=1.5) +
		scale_fill_manual(name='',
			labels=model_names,
			breaks=names(model_names),
			values=c('#F8766D', '#00BA38', '#619CFF')) +
		theme(
			axis.text.x = element_blank(),
			axis.ticks.x = element_blank(),
			axis.title.x = element_text(color='white')) + 
		labs(
			title=bquote('Proportion of simulations where the 95% CI covers '*beta['tx']),
			y='Proportion',
			caption=bquote('dashed line at '*alpha*'='*.(alpha))
			) +
		facet_nested(error_dist + beta_tx ~ n, 
			scales='free_x')

	p <- facet_labs(p, bquote('Error Distribution; '*beta['tx']), 'n')

	return(p)
}



not_coverage_plot <- function(){

	pdat <- reshape2::melt(coverage_tab, measure.vars=c('wald_coverage', 'bootp_coverage', 'boott_coverage'), value.name='coverage', variable.name='model')
	pdat$not_covered <- 1-pdat$coverage
	pdat$model <- gsub('_coverage', '', pdat$model)
	pdat$model <- factor(pdat$model, levels=c('wald', 'bootp', 'boott'))

	p <- ggplot(pdat, 
		aes(model, not_covered,
			fill=model)) + 
		geom_bar(stat='identity', width=0.5) +
		geom_hline(yintercept=alpha, linetype='dashed', size=0.5) +		
		geom_text(aes(x=-Inf, y=Inf, label=scenario),
			size=5, color='black', hjust=-0.5, vjust=1.5) +
		scale_fill_manual(name='',
			labels=model_names,
			breaks=names(model_names),
			values=c('#F8766D', '#00BA38', '#619CFF')) +
		theme(
			axis.text.x = element_blank(),
			axis.ticks.x = element_blank(),
			axis.title.x = element_text(color='white')) + 
		labs(
			title=bquote('Proportion of simulations where the 95% CI does NOT include '~beta['tx']),
			y='Proportion',
			caption=bquote('dashed line at '~alpha*'='*.(alpha))
			) +
		facet_nested(error_dist + beta_tx ~ n, 
			scales='free_x')

	p <- facet_labs(p, bquote('Error Distribution; '*beta['tx']), 'n')

	return(p)
}


# CI PLOT
ci_plot <- function(n, xlim=NULL, scales='fixed', ...) {

	p <- ggplot(mdat2[mdat2$n==n, ], 
		aes(j, beta_tx, 
			ymin=ci_lb, 
			ymax=ci_ub, 
			col=coverage)) +
		geom_point(alpha=1, size=1) +
		geom_errorbar(alpha=0.9, size=0.5) +
		geom_hline(aes(yintercept=beta_tx), size=0.5)+
		geom_text(aes(x=Inf, y=-Inf, label=scenario),
			size=5, color='black', hjust=-0.5, vjust=1.5) +
		guides(colour=guide_legend(
			override.aes=list(alpha=1, size=1, stroke=1, linewidth=2))) + 
		labs(
			title=paste0('Coverage of 95% CIs for n=', n),
			y=bquote(hat(beta)['tx']),
			x='simulation') + 
		facet_nested(error_dist + beta_tx ~ model, 
			scales=scales,
			labeller=label_parsed
		)

	# handle x-axis limits
	if(!is.null(xlim)){
		p <- p + coord_flip(ylim=xlim)
	} else {
		p  <-  p + coord_flip()
	}

	# label facets
	p <- facet_labs(p, bquote('Error Distribution::'*beta['tx']), 'method')

	return(p)
}




ci_width_plot_log <- function(scales='fixed', ...){

	p <- ggplot(mdat, 
			aes(y=ci_width, x=model, color=model)) + 
		geom_boxplot() +
		stat_summary(fun=mean, geom='point', 
			position=position_dodge(.9), 
			size=2.5, shape=18) +
		geom_text(aes(x=-Inf, y=Inf, label=scenario),
			size=5, color='black',hjust=-0.5, vjust=1.5) +
		scale_color_manual(name='',
			labels=model_names,
			breaks=names(model_names),
			values=c('#F8766D', '#00BA38', '#619CFF')) +
		labs(
			title=bquote('log(Width of 95% CI)'),
			x=NULL,
			y='log(CI Width)') + 
		scale_y_continuous(trans='log') +
		theme(
			axis.text.x = element_blank(),
			axis.ticks.x = element_blank(),
			axis.title.x = element_text(color='white')) + 
		facet_nested(error_dist + beta_tx ~ n, 
			scales=scales)

	p <- facet_labs(p, bquote('Error Distribution; '*beta['tx']), 'n')

	return(p)
}


ci_width_plot <- function(scales='fixed', ...){

	p <- ggplot(mdat, 
			aes(y=ci_width, x=model, color=model)) + 
		geom_boxplot() +
		stat_summary(fun=mean, geom='point', 
			position=position_dodge(.9), 
			size=2.5, shape=18) +
		geom_text(aes(x=-Inf, y=Inf, label=scenario),
			size=5, color='black',hjust=-0.5, vjust=1.5) +
		scale_color_manual(name='',
			labels=model_names,
			breaks=names(model_names),
			values=c('#F8766D', '#00BA38', '#619CFF')) +
		labs(
			title=bquote('Width of 95% CI'),
			x=NULL,
			y='CI Width') + 
		theme(
			axis.text.x = element_blank(),
			axis.ticks.x = element_blank(),
			axis.title.x = element_text(color='white')) + 
		facet_nested(error_dist + beta_tx ~ n, 
			scales=scales)

	p <- facet_labs(p, bquote('Error Distribution; '*beta['tx']), 'n')

	return(p)
}




## SE DIST PLOT

se_plot <- function(){
	p <- ggplot(dat, 
		aes(se)) + 
		geom_histogram(fill='#00BFC4') +
		geom_text(aes(x=-Inf, y=Inf, label=scenario),
			size=5, color='black', hjust=-0.5, vjust=1.5) +
		labs(
			# title='Distribution of Standard Error',
			title=bquote('Distribution of se('*hat(beta)*')'),
			x=bquote('se('*hat(beta)*')')
		) +
		facet_nested(error_dist + beta_tx ~ n, 
			scales='free_x')

	p <- facet_labs(p, bquote('Error Distribution; '*beta['tx']), 'n')

	return(p)
}



# TIME PLOT
time_plot <- function(){
	p <- ggplot(
			data=mdat, 
			aes(x=model, y=time, color=model)) + 
		geom_boxplot() +
		stat_summary(fun=mean, geom='point', 
			position=position_dodge(.9), 
			size=2.5, shape=18) +
		geom_text(aes(x=-Inf, y=Inf, label=scenario),
			size=5, color='black',hjust=-0.5, vjust=1.5) +
		scale_color_manual(name='',
			labels=model_names,
			breaks=names(model_names),
			values=c('#F8766D', '#00BA38', '#619CFF')) +
		labs(
			title=bquote('Computation Time for all scenarios'),
			x=NULL,
			y='Seconds') + 
		theme(
			axis.text.x = element_blank(),
			axis.ticks.x = element_blank(),
			axis.title.x = element_text(color='white')) +
		facet_nested(error_dist + beta_tx ~ n, 
			scales='free_x')

	p <- facet_labs(p, bquote('Error Distribution; '*beta['tx']), 'n')

	return(p)
}



