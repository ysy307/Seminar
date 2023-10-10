program laplace
	use omp_lib
	implicit none
	integer, parameter   :: n = 1024
	integer, parameter   :: ITMAX = 10000
	real(8), parameter   :: eps = 1.0e-10
	real(8), parameter   :: pi = 3.14159 
	real(8), parameter   :: omg = 2d0 / (1d0 + sin(pi / n))
	
	real(8), allocatable :: T(:,:)
	real(8)              :: rhs, err
	real(8)              :: ts, te, time
	integer              :: i, j, itr

	allocate(T(n + 2, n + 2))
	call set_dbc(n, T, 1)

	write(*, *) 'The number of partitions : ', n
	write(*, *) 'Relaxation factor        : ', omg
	
	ts = omp_get_wtime()
	do itr = 1, ITMAX
		err = 0d0
		!$omp parallel private(i, j, rhs)
		!$omp do reduction(+ : err)
		do j = 2, n + 1
			do i = 2, n + 1
				rhs = (T(i - 1, j) + T(i + 1, j) + T(i, j - 1) + T(i, j + 1)) / 4d0
				err = err + (rhs - T(i,j)) ** 2
				T(i, j) = T(i, j) + omg * (rhs - T(i, j))
			end do
		end do
		!$omp end do
		!$omp end parallel
		err = sqrt(err)
		if (err < eps) exit
	end do
	te = omp_get_wtime()
	time = te - ts
	write(*, *) 'The number of iteration  : ', itr
	write(*, *) 'Elapsed time             : ', time
	write(*, *) 'Residual norm            : ', err


	open(50, file = 'laplace.d')
	do j = 1, n + 1, n / 16
		do i = 1, n + 1, n / 16
			write(50, *) dble(i - 1) / n, dble(j - 1) / n, T(i,j)
		end do
		write(50, *) ' '
	end do

	deallocate(T)

  contains
  
  subroutine set_dbc(n, T, type)
    implicit none
    integer, intent(in)    :: n
    real(8), intent(inout) :: T(n + 2, n + 2)
    integer, intent(in)    :: type
    
    real(8), parameter     :: pi = 3.14159 
    integer i, j

    do j = 1, n + 2
      do i = 1, n + 2
        T(i, j) = 0
      end do
    end do

    if (type == 1) then
      do i = 1, n + 2
        T(i, 1) = 0
        T(1 ,i) = sin(pi * (i - 1) / n)
        T(i, n + 2) = 0
        T(n + 2 ,i) = 0
      end do
    end if

    if (type == 2) then
      do i = 1, n + 2
        T(i, 1) = 0
        if (dble(i - 1)/n > 0.25 .and. dble(i - 1)/n < 0.75) T(1 ,i) = 1
        T(i, n + 2) = 0
        T(n + 2 ,i) = 0
      end do
    end if

  end subroutine set_dbc
end program laplace