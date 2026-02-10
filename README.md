# bios731_hw2_parrish



---

- [Directories \& Files](#directories-and-files)
- [Reproducibility](#reproducibility)
- [Session Info](#session-info)


---


## Directories and Files

```

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


```


### RHPC

```R


```
