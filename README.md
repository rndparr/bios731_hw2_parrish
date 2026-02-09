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
- grid
- gtable
- here
- reshape2

```R
install.packages(c("doFuture", "dorng", "foreach", "ggplot2", "ggplotify", "grid", "gtable", "here", "reshape2"))
```


## Example Slurm Command on RHPC

Below is the an example of commands to submit an 18-task array job to Slurm, limiting the max number of concurrent tasks to 2 and setting the number of cores per task to 16:

```bash
# full path to project directory
pdir=/full/path/to/bios731_hw2_parrish
mkdir -p ${pdir}/logs

sbatch --job-name=run_sim_i --cpus-per-task=16 --array=1-18%2 --chdir=${pdir}/logs ${pdir}/source/sbatch_run_sim_i.sh
```


---



## Session Info

### Local Computer

```R


```


### RHPC

```R


```
