program ex01
	use omp_lib
	implicit none

	!$omp parallel
	print *, 'Hello World ', omp_get_num_threads(), omp_get_thread_num()
	!$omp end parallel
end program ex01
