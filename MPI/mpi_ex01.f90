program mpi_ex01
  use mpi
  implicit none

  integer :: nprocs, myrank, ierr

  call MPI_Init( ierr )
  call MPI_Comm_size( MPI_COMM_WORLD, nprocs, ierr )
  call MPI_Comm_rank( MPI_COMM_WORLD, myrank, ierr )

  print *, 'Hello, world!  My rank number and nprocs are', myrank, ',', nprocs

  call MPI_Finalize( ierr )
  stop
end program mpi_ex01
