program sum_allreduce
  use mpi
  implicit none

  integer :: n, i, istart, iend, isum_local, isum
  integer :: nprocs, myrank, ierr

  call MPI_Init( ierr )
  call MPI_Comm_size( MPI_COMM_WORLD, nprocs, ierr )
  call MPI_Comm_rank( MPI_COMM_WORLD, myrank, ierr )

  if( myrank==0)  n=10000
  call MPI_Bcast( n, 1, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr )

  istart =  myrank   *(n/nprocs) + 1
  iend   = (myrank+1)*(n/nprocs)

  isum_local = 0
  do i = istart, iend
    isum_local = isum_local + i
  enddo

  call MPI_Allreduce( isum_local, isum, 1, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, ierr )

  print *, 'Rank:', myrank,  '-> Local sum = ', isum_local
  print *, 'Rank:', myrank,  '-> Total sum = ', isum

  call MPI_Finalize( ierr )
  stop
end program sum_allreduce
