//Kernel to make diagonal element non zero
__global__ void rowExchange(float *devMatrix, int dim, int j, int i)
{
	int index = blockIdx.x*blockDim.x + threadIdx.x;
	__syncthreads();
	if(index<dim)
		//add jth row with ith row to make diagonal element non zero
		devMatrix[j*dim + index] = devMatrix[j*dim + index] + devMatrix[i*dim + index];
}