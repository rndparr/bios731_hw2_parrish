#!/bin/bash

# load R
module load R

# assumes working directory is /full/path/to/bios731_hw2_parrish/logs
# from ${wkdir}/logs, run the run_sim_i.R script
Rscript ../source/run_sim_i.R ${SLURM_ARRAY_TASK_ID} ${SLURM_CPUS_PER_TASK}

# unload R
module unload R
