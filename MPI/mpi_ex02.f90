program mpi_ex02
  use mpi
  implicit none

  integer :: i, istart, iend, isum_local, isum_recv
  integer :: nprocs, myrank, ierr

  call MPI_Init( ierr )
  call MPI_Comm_size( MPI_COMM_WORLD, nprocs, ierr )
  call MPI_Comm_rank( MPI_COMM_WORLD, myrank, ierr )

  istart = myrank*25 + 1
  iend   = (myrank+1)*25
  isum_local = 0

  do i = istart, iend
    isum_local = isum_local + i
  enddo

  if( myrank /= 0 ) then
    call MPI_Send( isum_local, 1, MPI_INTEGER, 0, 100, MPI_COMM_WORLD, ierr )
  else
    do i=1,3
      call MPI_Recv( isum_recv, 1, MPI_INTEGER, i, 100, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
      isum_local = isum_local + isum_recv
    enddo
  end if

  if( myrank == 0 )  print *, 'sum =', isum_local

  call MPI_Finalize( ierr )
  stop
end program mpi_ex02
