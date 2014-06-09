//Kernel to make diagonal element 1
__global__ void fixRows(float *devMatrix, int dim, int j)
{
	int index = blockIdx.x*blockDim.x + threadIdx.x;
	__shared__ float temp;
	temp = devMatrix[j*dim + j];
	__syncthreads();
	if(index<dim)
	{
		if(devMatrix[j*dim + index] != 0 && index !=j)
			devMatrix[j*dim + index] = devMatrix[j*dim + index]/temp;
	}
	if(index == dim-1)
		devMatrix[j*dim+j] = 1;  	
}