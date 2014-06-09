//Kernel to make elements in a column zero except diagonal element
__global__ void fixColumns(float *devMatrix, int dim, int colId)
{	
	int i = blockIdx.x;
	int j = threadIdx.x;
	int index = i*blockDim.x + j;
	int k = (int)(index/dim);
	int l = index%dim;
	float temp = devMatrix[k*dim+colId];
	__syncthreads();
	if(temp != 0 && index<(dim*dim/2))
	{
		if(k != colId && l != colId)
			devMatrix[k*dim +l ] = devMatrix[k*dim + l] -temp*devMatrix[colId*dim + l];
	}
	__syncthreads();
	if(k != colId && l == dim-1)
			devMatrix[k*dim+colId] = 0;
}
