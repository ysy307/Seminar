program sr_matrix
  use mpi
  implicit none

  integer,parameter :: N=20
  double precision :: u(0:N+1,0:N+1)
  integer :: i, j, js, je
  integer :: nprocs, myrank, left, right, srtag, ierr

  call MPI_Init( ierr )
  call MPI_Comm_size( MPI_COMM_WORLD, nprocs, ierr )
  call MPI_Comm_rank( MPI_COMM_WORLD, myrank, ierr )

  js = (N/nprocs)* myrank + 1
  je = (N/nprocs)*(myrank+1)

  left = myrank - 1
  if( myrank == 0 ) left = MPI_PROC_NULL

  right = myrank + 1
  if( myrank == nprocs-1 ) right = MPI_PROC_NULL

  u(0:N+1,0:N+1) = 0.0d0
  u(0:N+1,js:je) = (myrank+1)*10.0d0

! rightward data circulation
  call MPI_Sendrecv( u(0,je), N+2, MPI_DOUBLE_PRECISION, right, 100, &
  &                  u(0,js-1), N+2, MPI_DOUBLE_PRECISION, left, 100, &
  &                  MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr )

! leftward data circulation
  call MPI_Sendrecv( u(0,js), N+2, MPI_DOUBLE_PRECISION, left, 100, &
  &                  u(0,je+1), N+2, MPI_DOUBLE_PRECISION, right, 100, &
  &                  MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr )

  do i=0,nprocs-1
    if( myrank == i ) then
      print '("Rank=",i2," js:je=",i4,":",i4)', myrank, js, je
      print '(10f6.2)', (u(N/2,j),j=js-1,je+1)
      flush(6)
    end if
    call MPI_Barrier( MPI_COMM_WORLD, ierr )
  end do

  call MPI_Finalize( ierr )
  stop
end program sr_matrix

