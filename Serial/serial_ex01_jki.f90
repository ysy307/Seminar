program matrix_multiplication
  integer, parameter :: IMAX = 1024
  integer :: i, j, k
  real(8) :: a(IMAX, IMAX)
  real(8) :: b(IMAX, IMAX)
  real(8) :: c(IMAX, IMAX)
  real(8) :: start, end, elaps

  do j = 1, IMAX
    do i = 1, IMAX
      a(i, j) = sin(2.0d0 * dble(i) * dble(acos(-1.0d0)) / dble(IMAX)) * &
                sin(2.0d0 * dble(j) * dble(acos(-1.0d0)) / dble(IMAX))
      b(i, j) = cos(2.0d0 * dble(i) * dble(acos(-1.0d0)) / dble(IMAX)) * &
                cos(2.0d0 * dble(j) * dble(acos(-1.0d0)) / dble(IMAX))
      c(i, j) = 0.0d0
    end do
  end do

  call cpu_time(start)

  do j = 1, IMAX
    do k = 1, IMAX
      do i = 1, IMAX
        c(i, j)   = c(i, j)   + a(i, k) * b(k, j)
      end do
    end do
  end do

  call cpu_time(end)
  elaps = end - start

  print *, 'elapsed time =', elaps, ' sec'

end program matrix_multiplication
