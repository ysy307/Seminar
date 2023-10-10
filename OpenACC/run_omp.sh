#!/bin/bash
#PBS -q G
#PBS -l select=1:ncpus=10
#PBS -N job_omp
#PBS -j oe
source /etc/profile.d/modules.sh
module purge
module load nvhpc

cd ${PBS_O_WORKDIR}
rm -f omp.out
nvc -mp -O3 laplace_omp.c -o omp.out
#export KMP_AFFINITY=disabled
export OMP_NUM_THREADS=1
dplace ./omp.out
export OMP_NUM_THREADS=5
dplace ./omp.out
export OMP_NUM_THREADS=10
dplace ./omp.out





