#!/bin/bash
#PBS -N DLM
#PBS -l select=8:ncpus=48:mpiprocs=48
#PBS -l walltime=72:00:00
#PBS -P ne_gen
#PBS -k doe
#PBS -j oe

date

source /etc/profile.d/INL_modules.sh
module load use.restricted VASP/6.3.0_vtst

export OMP_NUM_THREADS=1
cd $PBS_O_WORKDIR

mpirun vasp_std

echo "Job finished."
date
