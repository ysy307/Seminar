program heat2d
  use mpi
  !$ use omp_lib
  implicit none

  integer,parameter :: N=128
  integer,parameter :: ITRmax=100000
  integer,parameter :: INTV=1

  integer :: nds, fp
  double precision :: dt, dr, s, diff, u_max
  double precision,allocatable :: u(:,:), u_new(:,:), u_global(:,:)
  integer :: i, j, step

  integer :: nprocs, myrank, left, right, src, ierr
  integer :: js, je, nsdom
  double precision :: diffl
  double precision :: t0, t1

!*MPI* Initialize MPI
  call MPI_Init( ierr )
  call MPI_Comm_size( MPI_COMM_WORLD, nprocs, ierr )
  call MPI_Comm_rank( MPI_COMM_WORLD, myrank, ierr )

! Define parameters
  dr = 1.0d0/(N+1)
  s  = 10.0d0

!*MPI* Define subdomain
  js = N*myrank/nprocs + 1
  je = N*(myrank + 1)/nprocs
  nsdom = je - js + 1
  print'("myrank=",i0,", js=",i0,", je=",i0,", nsdom=",i0)', myrank, js, je, nsdom

!*MPI* Set rank of left & right domains
  left = myrank - 1
  if( myrank == 0 ) left = MPI_PROC_NULL
  right = myrank + 1
  if( myrank == nprocs-1 ) right = MPI_PROC_NULL

! Memory allocation
  allocate(u(0:N+1,js-1:je+1),u_new(0:N+1,js:je),u_global(0:N+1,0:N+1))

! Initialization
  !$OMP parallel private(i,j)
  print*, "mythrd =", omp_get_thread_num()
  !$OMP do
  do j=js-1,je+1
    do i=0,N+1
      u(i,j) = 0.0d0
      if((j /= js-1).and.(j /= je+1)) u_new(i,j) = 0.0d0
    enddo
  enddo
  !$OMP enddo
  !$OMP do
  do j=0,N+1
    do i=0,N+1
      u_global(i,j) = 0.0d0
    enddo
  enddo
  !$OMP enddo
  !$OMP end parallel

!*MPI* Collect data to rank=0
  call MPI_Gather( u_new(0,js), (N+2)*nsdom, MPI_DOUBLE_PRECISION, &
 &                 u_global(0,0), (N+2)*nsdom, MPI_DOUBLE_PRECISION, &
 &                 0, MPI_COMM_WORLD, ierr )

! 1st-time data output
  if( myrank == 0 ) then
    nds = -1
    u_max = 0.0d0
    fp = 10
    open(fp, file="U2d.dat")
    call output(fp, N+2, N+2, u_global)
  endif

! Time advancement
  call MPI_Barrier( MPI_COMM_WORLD, ierr )
  t0 = MPI_Wtime()
  step = 0
  do
    step = step + 1
    diffl = 0.0d0

    !*MPI* boundary communication
    call MPI_Sendrecv( u(0,je),   N+2, MPI_DOUBLE_PRECISION, right, 100, &
   &                   u(0,js-1), N+2, MPI_DOUBLE_PRECISION, left, 100, &
   &                   MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr )
    call MPI_Sendrecv( u(0,js),   N+2, MPI_DOUBLE_PRECISION, left, 100, &
   &                   u(0,je+1), N+2, MPI_DOUBLE_PRECISION, right, 100, &
   &                   MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr )

    !$OMP parallel private(i,j)
    ! sole Heat Equation
    ! *new value u(m+1): u_new[][], old value u(m): u[][]
    ! *boundary condition: u[0][0] = u_new[0][0] = u[N+1][N+1] = u_new[N+1][N+1] = 0.0
    !$OMP do
    do j=js,je
      do i=1,N
        u_new(i,j) = (u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1))*0.25d0 + s*dr*dr
      enddo
    enddo
    !$OMP enddo

    ! check a difference between u(m+1) & u(m)
    !$OMP do reduction(+:diffl)
    do j=js,je
      do i=1,N
        diffl = diffl + (u_new(i,j) - u(i,j))*(u_new(i,j) - u(i,j))
      enddo
    end do
    !$OMP enddo

    ! Store u_new[] into u[]
    !$OMP do
    do j=js,je
      do i=1,N
        u(i,j) = u_new(i,j)
      enddo
    enddo
    !$OMP enddo
    !$OMP end parallel

    !*MPI* reduction of diff
    call MPI_Allreduce(diffl, diff, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD, ierr)
    diff = sqrt(diff)

    !*MPI* Collect data to rank=0
      call MPI_Gather( u_new(0,js), (N+2)*nsdom, MPI_DOUBLE_PRECISION, &
     &                 u_global(0,0), (N+2)*nsdom, MPI_DOUBLE_PRECISION, &
     &                 0, MPI_COMM_WORLD, ierr )

    ! Data output during iteration
    if( ( mod(step,INTV) == 1 ).and.( myrank == 0) ) call output(fp, N+2, N+2, u_global)

    if( (diff <= 1.0d-3).or.(step > ITRmax) ) exit
  enddo

  call MPI_Barrier( MPI_COMM_WORLD, ierr )
  t1 = MPI_Wtime()

  if( myrank == 0 ) then
    if( step < ITRmax ) then
      print*, 'Converged at: step =', step
    else
      print*, 'Reach ITRmax before converged: diff =', diff
    endif
    print*, 'Elapsed time:', t1 - t0
  endif

!*MPI* Collect data to rank=0
  call MPI_Gather( u_new(0,js), (N+2)*nsdom, MPI_DOUBLE_PRECISION, &
 &                 u_global(0,0), (N+2)*nsdom, MPI_DOUBLE_PRECISION, &
 &                 0, MPI_COMM_WORLD, ierr )

! Final data output
  if( myrank == 0 ) then
    call output(fp, N+2, N+2, u_global)
    close(fp)
    call gpscript
  endif

  call MPI_Finalize( ierr )
  stop

!----
contains

  subroutine output(fp, isize, jsize, data)
    integer,intent(in) :: fp
    integer,intent(in) :: isize, jsize
    double precision,intent(in) :: data(0:,0:)

    integer :: ii, jj

    do ii=0,isize-1
      do jj=0,jsize-1
        if( u_max < data(ii,jj) ) then
          u_max = data(ii,jj)
        endif
        write(fp,'(f8.6,2X,f8.6,2X,f8.6)') jj*dr, ii*dr, data(ii,jj)
      enddo
      write(fp,*) ""
    enddo
    write(fp,*) ""; write(fp,*) ""
    nds = nds + 1

    return
  end subroutine output

  subroutine gpscript
    integer :: fp = 10001

    open(fp, file="Uplot2d1.gp")
    write(fp, '("set pm3d map")')
    write(fp, '("set size square")')
    write(fp, '("set xlabel ",A)') "'x'"
    write(fp, '("set ylabel ",A)') "'y'"
    write(fp, '("set xrange[",f0.6,":",f0.6,"]")') 0.0, 1.0
    write(fp, '("set yrange[",f0.6,":",f0.6,"]")') 0.0, 1.0
    write(fp, '("set cbrange[",f0.6,":",f0.6,"]")') -u_max*0.1, u_max*1.1
    write(fp, '("set palette defined (",f0.6,A,f0.6,A,f0.6,A,")")') 0.0, " 'blue', ", u_max/2, " 'red', ", u_max, " 'yellow'"
    write(fp, '("unset ztics")')
    write(fp, '("set title ",A)') "'U distribution'"
    write(fp, '("set terminal png")')
    write(fp, '("set output ",A)') '"U2d1initial.png"'
    write(fp, '("splot ",A," index ",i0," using 1:2:3")') "'./U2d.dat'", 0
    write(fp, '("set output ",A)') '"U2d1interim.png"'
    write(fp, '("splot ",A," index ",i0," using 1:2:3")') "'./U2d.dat'", nds/4
    write(fp, '("set output ",A)') '"U2d1final.png"'
    write(fp, '("splot ",A," index ",i0," using 1:2:3")') "'./U2d.dat'", nds
    write(fp, '("set terminal x11 size 800,800")')
    write(fp, '("do for [ind = 0:",i0,"] {")') nds
    write(fp, '("splot ",A," index ind using 1:2:3")') "'./U2d.dat'"
    write(fp, '("pause 0.5")')
    write(fp, '("}")')
    close(fp)

    fp = 10002
    open(fp, file="Uplot2d2.gp")
    write(fp, '("set size square")')
    write(fp, '("set xlabel ",A)') "'x'"
    write(fp, '("set ylabel ",A)') "'y'"
    write(fp, '("set xrange[",f0.6,":",f0.6,"]")') 0.0, 1.0
    write(fp, '("set yrange[",f0.6,":",f0.6,"]")') 0.0, 1.0
    write(fp, '("set contour base")')
    write(fp, '("set cntrparam levels 10")')
    write(fp, '("set title ",A)') "'U distribution'"
    write(fp, '("set terminal png")')
    write(fp, '("set output ",A)') '"U2d2initial.png"'
    write(fp, '("splot ",A," index ",i0," every 2 using 1:2:3")') "'./U2d.dat'", 0
    write(fp, '("set output ",A)') '"U2d2interim.png"'
    write(fp, '("splot ",A," index ",i0," every 2 using 1:2:3")') "'./U2d.dat'", nds/4
    write(fp, '("set output ",A)') '"U2d2final.png"'
    write(fp, '("splot ",A," index ",i0," every 2 using 1:2:3")') "'./U2d.dat'", nds
    write(fp, '("set terminal x11 size 800,800")')
    write(fp, '("splot ",A," index ",i0," every 2 using 1:2:3")') "'./U2d.dat'", nds
    close(fp)

    print'(X,A)', 'To visualize data, run "gnuplot -persist Uplot2d1.gp" or "gnuplot -persist Uplot2d2.gp".'

    return
  end subroutine gpscript


end program heat2d
