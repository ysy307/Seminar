program main
  integer, parameter :: IMAX = 8196
  real(8) :: a(IMAX, IMAX)
  real(8) :: x, y, sum
  integer :: i, j
  real(8) :: start, end, elaps

  call cpu_time(start)
  write(*,*) 'start clock'

  do i = 1, IMAX
    do j = 1, IMAX
      x = 5.0d0 * real(i-1) / real(IMAX)
      y = 5.0d0 * real(j-1) / real(IMAX)
      a(i, j) = 4.0d0 / dble(acos(-1.0d0)) * exp(-x*x - y*y)
    end do
  end do

  sum = 0.0d0
  do i = 1, IMAX
    do j = 1, IMAX
      sum  = sum + a(i, j)
    end do
  end do

  sum = sum * 25.0d0 / dble(IMAX) / dble(IMAX)
  call cpu_time(end)
  
  elaps = end - start
  write(*,*) 'sum=', sum
  write(*,*) 'elapsed time=', elaps, ' sec'
end program main
