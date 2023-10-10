program normalize_mpi
  use mpi
  implicit none

  integer,parameter :: N = 50000
  integer :: istart, iend, i
  double precision :: x(N), sum_local, sum, cnst, err_local, err
  integer :: nprocs, myrank, ierr

  call MPI_Init( ierr )
  call MPI_Comm_size( MPI_COMM_WORLD, nprocs, ierr )
  call MPI_Comm_rank( MPI_COMM_WORLD, myrank, ierr )

  istart =  myrank   *(n/nprocs) + 1
  iend   = (myrank+1)*(n/nprocs)
  print*, '(start,end) =', istart, iend, 'for myrank:', myrank

  sum_local = 0.0d0
  do i = istart, iend
    x(i) = i
    sum_local = sum_local + x(i)*x(i)
  enddo

  call MPI_Allreduce( sum_local, sum, 1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr )
  sum = 1.0d0/sqrt(sum)

  do i = istart, iend
    x(i) = x(i)*sum
  enddo

  cnst = 1.0d0/sqrt((N*(N + 1.0d0)*(2.0d0*N + 1.0d0))/6.0d0)
  err_local = 0.0d0
  do i = istart, iend
    err_local = err_local + abs( x(i) - i*cnst )
  enddo

  call MPI_Reduce( err_local, err, 1, MPI_DOUBLE_PRECISION, MPI_SUM, 0, MPI_COMM_WORLD, ierr )

  if( myrank == 0 ) print *, 'Error =', err

  call MPI_Finalize( ierr )
  stop
end program normalize_mpi

