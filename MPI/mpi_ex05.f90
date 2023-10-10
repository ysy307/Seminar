program srseparate
  use mpi
  implicit none

  integer,parameter :: N=100
  double precision :: a0(N), a1(N)
  integer :: i
  integer :: nprocs, myrank, ierr

  call MPI_Init( ierr )
  call MPI_Comm_size( MPI_COMM_WORLD, nprocs, ierr )
  call MPI_Comm_rank( MPI_COMM_WORLD, myrank, ierr )

  if( myrank == 0 ) then
    a0(1:N) = 1.0d0
    a1(1:N) = -99.0d0
  else
    a0(1:N) = 2.0d0
    a1(1:N) = -99.0d0
  endif

  if( myrank == 0 ) print*, 'Before exchange... rank: 0, a0(1)=', int(a0(1)), 'a1(1)=', int(a1(1))
  call MPI_Barrier( MPI_COMM_WORLD, ierr )
  if( myrank == 1 ) print*, 'Before exchange... rank: 1, a0(1)=', int(a0(1)), 'a1(1)=', int(a1(1))

  if( myrank == 0 ) then
    call MPI_Send( a0(0), N, MPI_DOUBLE_PRECISION, 1, 100, MPI_COMM_WORLD, ierr )
    call MPI_Recv( a1(0), N, MPI_DOUBLE_PRECISION, 1, 200, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr )
  else
    call MPI_Recv( a1(0), N, MPI_DOUBLE_PRECISION, 0, 100, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr )
    call MPI_Send( a0(0), N, MPI_DOUBLE_PRECISION, 0, 200, MPI_COMM_WORLD, ierr )
  endif

  if( myrank == 0 ) print*, 'After exchange... rank: 0, a0(1)=', int(a0(1)), 'a1(1)=', int(a1(1))
  call MPI_Barrier( MPI_COMM_WORLD, ierr )
  if( myrank == 1 ) print*, 'After exchange... rank: 1, a0(1)=', int(a0(1)), 'a1(1)=', int(a1(1))

  call  MPI_Finalize( ierr )
  stop
end program srseparate
