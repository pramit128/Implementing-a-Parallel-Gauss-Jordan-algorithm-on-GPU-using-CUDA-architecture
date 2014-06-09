#include<stdio.h>
#include<time.h>
#include<stdlib.h>
#include "rowExchange.h"
#include "fixRows.h"
#include "fixColumns.h"
#define seed 1
#include "inputmatrix.h"

	
int main()
{
	FILE *outFile, *inFile, *vFile;
	
	inFile = fopen("matrix.txt","w");
	
	printf("Opening file matrix.txt...\n\n");
	//check if there is error in opening file
	
	if(inFile==NULL)
	{
		perror("File read error.");
		exit(1);
	}

	outFile = fopen("inverse.txt","w");
	
	printf("Opening file inverse.txt...\n\n");
	
	//check if there is error in opening file
	if(outFile==NULL)
	{
		perror("File read error.");
		exit(1);
	}
	
	int size, columns, threads;
	int choice;
	int j = 0;
	
	printf("Please enter the size of input matrix. Enter x for matrix of size x*x\n");
	scanf("%d", &size);
	
	columns = 2*size; //double the size of the matrix for augmenting the identity matrix
		
	if(columns < 1025)
		threads = columns % 1025;	
	else
		threads = 1024;
		
	dim3 thread(threads);
	dim3 rBlock((int)ceil(columns/threads)+1);
	dim3 cBlock((int)ceil(size*columns/threads)+1);
	
	float *matrix, *inMatrix, *rMatrix, *invMatrix;		
	float *devMatrix;	//the device matrix
	
	printf("\nAllocating memory in CPU...\n");
	matrix = (float*)malloc(size*columns*sizeof(float));	//allocate memory
	inMatrix = (float*)malloc(size*size*sizeof(float));	//allocate memory
	rMatrix = (float*)malloc(size*size*sizeof(float));	//allocate memory
	invMatrix = (float*)malloc(size*size*sizeof(float));	//allocate memory
	
	printf("\nAllocating memory in CPU complete...\n");

	printf("\nEnter the type of matrix you wish to generate\n");
	printf("1 Random Matrix\n");
	printf("2 Sparse Matrix\n");
	printf("3 Identity Matrix\n");
	printf("4 Band Matrix\n");
	printf("5 Hollow Matrix\n");
	printf("6 Exit\n");
	scanf("%d", &choice);

	switch(choice)
	{
		case 1:
			randomMatrix(matrix, size, columns);
			printf("\nRandom matrix generated...\n");
			break;
							
		case 2:
			sparseMatrix(matrix, size, columns);
			printf("\nSparse Matrix generated...\n");
			break;
							
		case 3:
			identityMatrix(matrix, size, columns);
			printf("\nIdentity Matrix generated...\n");
			break;
							
		case 4:
			bandMatrix(matrix, size, columns);
			printf("\nBand Matrix generated...\n");
			break;

		case 5:
			hollowMatrix(matrix, size, columns);
			printf("\nHollow Matrix generated...\n");
			break;
							
		case 6: 
			printf("\nExiting program...\n");
			exit(0);
			break;
		default:
			printf("\nInvalid Entry");
			printf("Exiting program...\n\n");
			exit(0);
			break;
				
				
	}
	
	printf("\nWriting input matrix to matrix.txt...\n");

	//print initialized matrix[] in a text file
	fprintf(inFile,":::::INPUT MATRIX IS:::::\n\n");
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<size; j++)
		{	
			//Initialize matrices to verify inverse computation
			inMatrix[i*size+j] = matrix[i*columns+j];
			rMatrix[i*size+j] = 0;
			fprintf(inFile,"%.3f\t", matrix[i*columns+j]);
		}
		fprintf(inFile,"\n\n");
	}

	printf("\nWriting input matrix to matrix.txt complete...\n");
	
	//Declare event object variables
	cudaEvent_t start, finish;
	
	//Time taken for computation
	float duration;
	
	//Create event objects
	cudaEventCreate(&start);
	cudaEventCreate(&finish);

	//allocate memory in the device
	cudaMalloc((void**)&devMatrix, size * columns * sizeof(float));

	//Record event at the before start of computation
	cudaEventRecord(start, 0);
	
	printf("\nComputing Inverse...\n");

	//Wait until event start is actually recorded.
	cudaEventSynchronize(start);

	//copy matrix from host memory to device memory
	cudaMemcpy(devMatrix, matrix, size * columns * sizeof(float), cudaMemcpyHostToDevice);
	
	
	while(j<size)
	{
		if(matrix[j*columns+j]==0)
		{
			int i = 0;
			for(i=j+1; i<size; i++)
			{
				if(matrix[i*columns+j] != 0)
					break;
			}

			//Call kernel rowExchange() that makes diagonal element non zero
			rowExchange<<<rBlock, thread>>>(devMatrix, columns, j, i);
		}
		
		//Make diagonal element 1 by dividing whole row by itself
		fixRows<<<rBlock, thread>>>(devMatrix, columns, j);

		//Make elements in a column zero except diagonal element
		fixColumns<<<cBlock, thread>>>(devMatrix, columns, j);
		
		j++;
	}
	
	//copy matrix from device memory to host memory
	cudaMemcpy(matrix, devMatrix, size * columns * sizeof(float), cudaMemcpyDeviceToHost);

	//Record event after the end of computation
	cudaEventRecord(finish, 0);
	
	printf("\nInverse for the input matrix has been computed...\n");
	
	//Wait until event finish is actually recorded.
	cudaEventSynchronize(finish);
	
	//The time elapsed (in milliseconds) between events start and finish will be stored in variable duration.
	cudaEventElapsedTime(&duration, start, finish);

	//Destroy start event
	cudaEventDestroy(start);
	
	//Destroy finish event
	cudaEventDestroy(finish);

	//Free device memory
	cudaFree(devMatrix);
	
	printf("\nThe time taken for computing the inverse of the input matrix is = %.3f MILLISECONDS\n",duration);
	
	printf("\nWriting to inverse.txt...\n");

	//print inverse of given matrix computed by applying Gauss Jordan Elimination
	fprintf(outFile,":::::INVERSE OF GIVEN MATRIX IS:::::\n\n");
	for(int i=0; i<size; i++)
	{
		
		for(int j=size; j<columns; j++)
		{
			invMatrix[i*size+j-size] = matrix[i*columns+j];
			fprintf(outFile,"%.3f\t", matrix[i*columns+j]);
		}
		fprintf(outFile,"\n\n");
	}
	
	printf("\nWriting to inverse.txt complete...\n");

	//print computation time on console and output file
	
	fprintf(outFile,":::TIME TAKEN FOR COMPUTATION IS::::\t%.3f MILLISECONDS\n\n",duration);
	
	printf("\nClosing file inverse.txt...\n");
	fclose(outFile);
	printf("\nClosing file matrix.txt...\n");
	fclose(inFile);

	/*
	
	printf("\nPreparing for verification by multiplying the input matrix and the computed inverse matrix...\n");
	
	//Multiply input matrix and resulting inverse matrix so that it can result into identity matrix
	//If the result is identity matrix, the computation is justified to be correct
	for(int i=0; i<size; i++)
		for(int j=0; j<size; j++)
			for(int k=0; k<size; k++)
				rMatrix[i*size+j] += inMatrix[i*size+k]*invMatrix[k*size+j];
	//End of matrix multiplication logic
	
	printf("\nOpening file verify.txt...\n");
	
	vFile = fopen("verify.txt","w");
	//check if there is error in opening file
	if(vFile==NULL)
	{
		perror("File read error.");
		exit(1);
	}
	
	printf("\nWriting to file verify.txt...\n");
	
	fprintf(vFile,"\n :::Multiplication of input matrix and inverse matrix is::: \n");
	
	printf("\nWriting to file verify.txt complete...\n");
	
	for(int i=0; i<size; i++)
	{
		
		for(int j=0; j<size; j++)
		{
			fprintf(vFile, "%1.0f\t", rMatrix[i*size+j]);
		}
		fprintf(vFile, "\n\n");
	}
	
	printf("\nClosing file verify.txt...\n");
	fclose(vFile);
	*/
	printf("\nFree up memory...\n");
	free(matrix);
	free(inMatrix);
	free(rMatrix);
	free(invMatrix);
	printf("\nProgram complete...\n");
	return 0;
}

