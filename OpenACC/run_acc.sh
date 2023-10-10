#!/bin/bash
#PBS -q G
#PBS -l select=1:ncpus=1:ngpus=1
#PBS -N job_acc
#PBS -j oe
source /etc/profile.d/modules.sh
module purge
module load nvhpc/21.1

cd ${PBS_O_WORKDIR}
export NVCOMPILER_ACC_TIME=1
#export NVCOMPILER_ACC_NOTIFY=2
rm -f acc.out
nvc -acc laplace_acc.c -o acc.out
./acc.out
