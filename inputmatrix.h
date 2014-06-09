//Function to generate random matrix
void randomMatrix(float *matrix, int size, int columns)
{
	//Make sure program generates same matrix for a given size on every run
	srand(seed);

	//initialize matrix and iMatrix(identity matrix)
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<columns; j++)
		{
			if(j>=size)
			{
				if(i==j-size)
					matrix[i*columns+j] = 1;
				else
					matrix[i*columns+j] = 0;
			}
			else
				matrix[i*columns+j] = rand()%1000 + 1;
			
			
		}
	}
}

//Function to generate sparse matrix
void sparseMatrix(float *matrix, int size, int columns)
{
	//Make sure program generates same matrix for a given size on every run
	srand(seed);

	int count = 0;
	//initialize matrix and iMatrix(identity matrix)
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<columns; j++)
		{
			if(j>=size)
			{
				if(i==j-size)
					matrix[i*columns+j] = 1;
				else
					matrix[i*columns+j] = 0;
			}
			else
			{
				if(count == 0 || i == j)
				{
					matrix[i*columns+j] = rand()%1000 + 1;
					count = 2;
				}
				else
				{
					matrix[i*columns+j] = 0;
					count--;
				}
			
			}
		}
	}
}

//Function to generate identity matrix
void identityMatrix(float *matrix, int size, int columns)
{
	//Make sure program generates same matrix for a given size on every run
	srand(seed);

	//initialize matrix and iMatrix(identity matrix)
	for(int i=0; i<size; i++)
	{
		for(int j=0; j<columns; j++)
		{
			if(j>=size)
			{
				if(i==j-size)
					matrix[i*columns+j] = 1;
				else
					matrix[i*columns+j] = 0;
			}
			else
			{
				if(i==j)
					matrix[i*columns+j] = 1;
				else
					matrix[i*columns+j] = 0;
			}
			
		}
	}
}

//Function to generate band matrix
void bandMatrix(float *matrix, int size, int columns)
{
	//Make sure program generates same matrix for a given size on every run
	srand(seed);

	for(int i = 0; i < size; i++)
	{
		for(int j = 0; j < columns; j++)
		{
			if(j >=size)
			{
				if(i == j - size)
					matrix[i * columns + j] = 1;
				else
					matrix[i * columns + j] = 0;
			}

			else if (i == j)
			{
	                	matrix[i * columns + j] = rand() % 1000 + 1;
			}
                	else if ( i == j - 1)
                    		matrix[i * columns + j] = rand() % 1000 + 1;

                	else if ( i == j + 1)
                    		matrix[i * columns + j] = rand() % 1000 + 1;

			else
			{

				matrix[i * columns + j] = 0;
			}

		}

	}
}

//Function to generate hollow matrix
void hollowMatrix(float *matrix, int size, int columns)
{
	//Make sure program generates same matrix for a given size on every run
	srand(seed);

	for(int i = 0; i < size; i++)
	{
		for(int j = 0; j < columns; j++)
		{
			if(j >=size)
			{
				if(i == j - size)
					matrix[i * columns + j] = 1;
				else
					matrix[i * columns + j] = 0;
			}

			else if (i == j)
			{
	                	matrix[i * columns + j] = 0;
			}
                	else if ( i == j - 1)
                    		matrix[i * columns + j] = 0;

                	else if ( i == j + 1)
                    		matrix[i * columns + j] = 0;

			else
			{

				matrix[i * columns + j] = rand() % 1000 + 1;
			}

		}

	}
}