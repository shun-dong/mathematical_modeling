/*
 * Stand-alone codes for fuzzy inference systems.
 * J.-S. Roger Jang, 1994.
 * Copyright (c) 1994-98 by The MathWorks, Inc.
 * $Revision: 1.3 $  $Date: 1997/12/01 21:44:55 $
 */

/* This part is for MACs only */
#if defined(applec) || defined(__MWERKS__) || defined (THINK_C) || defined(powerc)

#include <stdio.h>
#include <stdarg.h>

FILE	*output_file;

#define printf macprintf

int macprintf(char* format, ...)	
{
	va_list	arg;
	int		ret;
	
	va_start(arg, format);
	ret = vfprintf(output_file, format, arg);
	va_end(arg);
	
	return(ret);
}
#endif /* applec || __MWERKS__ || THINK_C || powerc */

/* Start of the regular fismain.c */
#include "fis.c"

/***********************************************************************
 Main routine 
 **********************************************************************/

int
main(int argc, char **argv)
{
	FIS *fis;
	int i, j;
	int debug = 0;

	double **dataMatrix, **fisMatrix, **outputMatrix;
	char *fis_file, *data_file;
	int data_row_n, data_col_n, fis_row_n, fis_col_n;

#if defined(applec) || defined(__MWERKS__) || defined (THINK_C) || defined(powerc)
	/* For MACs only */
	data_file = "fismain.in";
	fis_file = "fismain.fis";
	output_file = fisOpenFile("fismain.out","w");
#else
	/* input arguments checking */
	if (argc != 3) {
		printf("Usage: %s data_file fis_file\n", argv[0]);
		exit(1);
	}
	data_file = argv[1];
	fis_file = argv[2];
#endif /* applec || __MWERKS__ || THINK_C || powerc */

	/* obtain data matrix and FIS matrix */
	dataMatrix = returnDataMatrix(data_file, &data_row_n, &data_col_n);
	fisMatrix = returnFismatrix(fis_file, &fis_row_n, &fis_col_n);

	/* build FIS data structure */
	fis = (FIS *)calloc(1, sizeof(FIS));
	fisBuildFisNode(fis, fisMatrix, fis_col_n);

	/* error checking */
	if (data_col_n < fis->in_n) {
		printf("Given FIS is a %d-input %d-output system.\n",
			fis->in_n, fis->out_n);
		printf("Given data file does not have enough input entries.\n");
		fisFreeMatrix((void **)dataMatrix, data_row_n);
		fisFreeMatrix((void **)fisMatrix, fis_row_n);
		fisFreeFisNode(fis);
		fisError("Exiting ...");
	}

	/* debugging */
	if (debug)
		fisPrintData(fis);

	/* create output matrix */
	outputMatrix = (double **)fisCreateMatrix(data_row_n, fis->out_n, sizeof(double));

	/* evaluate FIS on each input vector */
	for (i = 0; i < data_row_n; i++)
		getFisOutput(dataMatrix[i], fis, outputMatrix[i]);

	/* print output vector */
	for (i = 0; i < data_row_n; i++) {
		for (j = 0; j < fis->out_n; j++)
			printf("%.12f ", outputMatrix[i][j]);
		printf("\n");
	}

	/* clean up memory */
	fisFreeFisNode(fis);
	fisFreeMatrix((void **)dataMatrix, data_row_n);
	fisFreeMatrix((void **)fisMatrix, fis_row_n);
	fisFreeMatrix((void **)outputMatrix, data_row_n);
	exit(0);
}
