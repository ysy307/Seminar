program omp_ex04
  use omp_lib
  implicit none
  double precision :: a = 0
  integer :: i

  !$omp parallel do reduction(+:a)
  do i = 1, 100
    a = a + i
  end do
  !$omp end parallel do
  
  print *, a
end program omp_ex04