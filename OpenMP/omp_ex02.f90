program omp_ex02
  use omp_lib
  implicit none

  real(8) :: u(100), pi = 3.14159
  integer :: i

  !$omp parallel
  do i = 1, 100
    u(i) = sin(2.0 * pi * dble(i)/100.0)
    print *, 'myid=', omp_get_thread_num(), ',i=', i, ',u=', u(i)
  end do
  !$omp end parallel
end program omp_ex02