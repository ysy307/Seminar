#include <stdio.h>
#include <math.h>
#include <time.h>
#include <omp.h>

#define nmax 256
int main(void){
	int i,j;
	const double dx=1.0/nmax;
	double T[nmax+1][nmax+1];
	double Told[nmax+1][nmax+1];
	int n;
	double err;
	const int loop=100000;	
	FILE *fp;
	double t0, t1;
	const int nd=loop/10;

	t0=omp_get_wtime();

	//boundary
//#pragma omp parallel for
#pragma acc kernels
	for(i=1;i<=nmax-1;i++){
		T[i][0]=0.0;
		T[i][nmax]=0.0;
	}

//#pragma omp parallel for
#pragma acc kernels
	for(j=0;j<=nmax;j++){
		T[0][j]=0.0;
		T[nmax][j]=0.0;
	}

	//initial
#pragma acc kernels
	for(i=1;i<=nmax-1;i++)
		for(j=1;j<=nmax-1;j++)
			T[i][j]=0.0;

#pragma acc data create(Told) copy(T)
{
	for(n=0;n<loop;n++)
	{
//#pragma omp parallel for private(i,j)
#pragma acc kernels present(T,Told)
		for(i=0;i<=nmax;i++)
			for(j=0;j<=nmax;j++)
				Told[i][j]=T[i][j];
//#pragma omp parallel for private(i,j)
#pragma acc kernels present(T,Told)
		for(i=1;i<=nmax-1;i++)
			for(j=1;j<=nmax-1;j++)
				T[i][j]=0.25*(Told[i-1][j]+Told[i+1][j]+Told[i][j-1]+Told[i][j+1]+10.0*dx*dx);

		if((n%nd) == 0)
		{
			err=0.0;
//#pragma omp parallel for reduction(+:err) private(i,j)
#pragma acc kernels present(T,Told)
			for(i=1;i<=nmax-1;i++)
				for(j=1;j<=nmax-1;j++)
					err+=pow(T[i][j]-Told[i][j],2.0);
				
			err=sqrt(err);	
			printf("step=%5d, err=%5.2e\n",n,err);
		}
	}
}

	t1=omp_get_wtime();

	printf("time = %g [s]\n",t1-t0);

	fp = fopen("laplace_acc.dat","w");
	for(j=0;j<nmax+1;j++){
		for(i=0;i<nmax+1;i++)
			fprintf(fp,"%10.3le %10.3le %10.3le\n",
					(double)i/nmax,(double)j/nmax,T[i][j]);
		fprintf(fp,"\n");
	}
	fclose(fp);

	return 0;
}
