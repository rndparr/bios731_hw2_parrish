# bios731_hw2_parrish



---

- [Directories \& Files](#directories-and-files)
- [Reproducibility](#reproducibility)
- [Session Info](#session-info)


---


## Directories and Files

```
.
├── .gitignore
├── README.md
├── analysis
│    ├── HW2_final_report.Rmd
│    └── HW2_final_report.pdf
├── bios731_hw2_parrish.Rproj
├── data
│    └── all_data.Rds
├── results
│    ├── bias-plot-1.pdf
│    ├── ci-plot-width-1.pdf
│    ├── ci-plots-1.pdf
│    ├── ci-plots-2.pdf
│    ├── ci-plots-3.pdf
│    ├── ci-plots-4.pdf
│    ├── ci-plots2-1.pdf
│    ├── coverage-plot-1.pdf
│    ├── se-plot-1.pdf
│    └── time-plot-1.pdf
└── source
    ├── ci_coverage.R
    ├── error_funcs.R
    ├── merge_data.R
    ├── models.R
    ├── plot_functions.R
    ├── run_sim_i.R
    ├── sbatch_run_sim_i.sh
    ├── simulate_data.R
    ├── tables.R
    └── utility.R
```




---



## Reproducibility


### Required R packages
- doFuture
- dorng
- foreach
- ggplot2
- ggplotify
- ggh4x
- grid
- gtable
- here
- kableExtra
- reshape2


```R
install.packages(c("doFuture", "dorng", "foreach", "ggplot2", "ggplotify", "ggh4x","grid", "gtable", "here", "kableExtra", "reshape2"))
```


## Example Slurm Command on RHPC


From the project directory, the simulation for scenario i can also be run with the command: 
```R 
i=#scenario to run
ncores=# number of cores to use
Rscript ./source/run_sim_i.R ${i} ${ncores}
```

However, the factorial design means this may not be computationally feasible to run on a laptop. Instead, the simulation study was run on the RHPC cluster. 

Below is the an example of shell commands to submit an 18-task array job to Slurm, limiting the max number of concurrent tasks to 2 and setting the number of cores per task to 16:

```bash
# full path to project directory on cluster
pdir=/full/path/to/bios731_hw2_parrish
mkdir -p ${pdir}/logs

sbatch --job-name=run_sim_i --cpus-per-task=16 --array=1-18%2 --chdir=${pdir}/logs ${pdir}/source/sbatch_run_sim_i.sh
```

A file for each scenario *i* is saved as `./data/scenario_${i}.Rds` and can be copied from the cluster to a local folder using `scp`. An example command is shown below:

```bash 
scp user@cluster:/full/path/to/bios731_hw2_parrish/data/scenario_${i}.Rds /local/full/path/to/bios731_hw2_parrish/data/
```

Once all jobs are finished, run `Rscript ./source/merge_data.R` in bash or `source(here::here('source', 'merge_data.R'))` in R to combine the data from all scenarios into a single file called `./data/all_data.Rds`.

---



## Session Info

### Local Computer

```R
R version 4.2.3 (2023-03-15)
Platform: x86_64-apple-darwin17.0 (64-bit)
Running under: macOS Big Sur ... 10.16

Matrix products: default
BLAS:   /Library/Frameworks/R.framework/Versions/4.2/Resources/lib/libRblas.0.dylib
LAPACK: /Library/Frameworks/R.framework/Versions/4.2/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods  
[8] base     

other attached packages:
[1] gtable_0.3.6     ggh4x_0.3.1      ggplotify_0.1.2  ggplot2_4.0.2   
[5] kableExtra_1.4.0

loaded via a namespace (and not attached):
 [1] Rcpp_1.1.1         plyr_1.8.9         compiler_4.2.3     pillar_1.9.0      
 [5] RColorBrewer_1.1-3 yulab.utils_0.1.4  tools_4.2.3        digest_0.6.35     
 [9] memoise_2.0.1      evaluate_1.0.5     lifecycle_1.0.4    tibble_3.2.1      
[13] viridisLite_0.4.2  pkgconfig_2.0.3    rlang_1.1.7        cli_3.6.5         
[17] rstudioapi_0.16.0  xfun_0.56          fastmap_1.1.1      withr_3.0.2       
[21] stringr_1.5.1      dplyr_1.1.4        xml2_1.3.6         knitr_1.51        
[25] fs_1.6.6           gridGraphics_0.5-1 generics_0.1.3     vctrs_0.6.5       
[29] systemfonts_1.1.0  rprojroot_2.1.1    tidyselect_1.2.1   here_1.0.2        
[33] svglite_2.1.3      glue_1.8.0         R6_2.6.1           fansi_1.0.6       
[37] rmarkdown_2.30     reshape2_1.4.4     farver_2.1.1       magrittr_2.0.3    
[41] scales_1.4.0       htmltools_0.5.9    S7_0.2.1           utf8_1.2.4        
[45] stringi_1.8.4      cachem_1.0.8  
```


### RHPC

```R
R version 4.2.2 (2022-10-31)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Rocky Linux 8.10 (Green Obsidian)

Matrix products: default
BLAS:   /apps/R/4.2.2/lib64/R/lib/libRblas.so
LAPACK: /apps/R/4.2.2/lib64/R/lib/libRlapack.so

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
 [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
 [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] doRNG_1.8.6.3  rngtools_1.5.2 doFuture_1.2.0 future_1.69.0  foreach_1.5.2 

loaded via a namespace (and not attached):
 [1] compiler_4.2.2      here_1.0.2          parallelly_1.46.1  
 [4] rprojroot_2.1.1     tools_4.2.2         parallel_4.2.2     
 [7] future.apply_1.11.2 listenv_0.9.1       codetools_0.2-18   
[10] iterators_1.0.14    digest_0.6.31       globals_0.19.0    
```
