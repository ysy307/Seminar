@echo off
set OMP_NUM_THREADS=8
ifort \ *Your Path* \HPC_Semi\omp_Laplace.f90 -o \ *Your Path* \HPC_Semi\omp_Laplace.exe /Qopenmp /Od /check:all /traceback /fpe-all:0 /warn:all /debug:full
rem Check if the compilation was successful
if %errorlevel%==0 (
  echo Compilation is completed.
  \ *Your Path* \HPC_Semi\omp_Laplace.exe
) else (
  echo Compilation error occurred.
)
