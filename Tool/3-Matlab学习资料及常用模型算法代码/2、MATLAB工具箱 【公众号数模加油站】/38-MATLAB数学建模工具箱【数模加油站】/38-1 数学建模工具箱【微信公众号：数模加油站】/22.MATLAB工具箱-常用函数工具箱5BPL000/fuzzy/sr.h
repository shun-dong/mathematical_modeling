/* ANFIS for MATLAB MEX file
 * J.-S. Roger Jang, 1994.
 * Copyright (c) 1995 by The MathWorks, Inc.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/***********************************************************************
 Macros and definitions
 **********************************************************************/

#define ABS(x)   ( (x) > (0) ? (x): (-(x)) )
#define MAX(x,y) ( (x) > (y) ? (x) : (y) )
#define MIN(x,y) ( (x) < (y) ? (x) : (y) )
#define MF_PARA_N 4
#define STR_LEN 500
#define MF_POINT_N 101

/* debugging macros */
#define PRINT(expr) printf(#expr " = %g\n", (double)expr)
#define PRINTMAT(mat,m,n) printf(#mat " = \n"); fisPrintMatrix(mat,m,n)
#define PRINTARRAY(mat,m) printf(#mat " = \n"); fisPrintArray(mat,m)

/*
#define FREEMAT(mat,m) printf("Free " #mat " ...\n"); fisFreeMatrix(mat,m)
#define FREEARRAY(array) printf("Free " #array " ...\n"); free(array)
*/

/*
*/
#define FREEMAT(mat,m) fisFreeMatrix(mat,m)
#define FREEARRAY(array) free(array)

/***********************************************************************
 Data types
 **********************************************************************/

/* FIS node which contains global information */
typedef struct fis_node {
	int handle;
	int load_param;
	char name[STR_LEN];
	char type[STR_LEN];
	char andMethod[STR_LEN];
	char orMethod[STR_LEN];
	char impMethod[STR_LEN];
	char aggMethod[STR_LEN];
	char defuzzMethod[STR_LEN];
	int userDefinedAnd;
	int userDefinedOr;
	int userDefinedImp;
	int userDefinedAgg;
	int userDefinedDefuzz;
	int in_n;
	int out_n;
	int rule_n;
	int **rule_list;
	double *rule_weight;
	int *and_or;	/* AND-OR indicator */
	double *firing_strength;
	double *rule_output;
	/* Sugeno: output for each rules */
	/* Mamdani: constrained output MF values of rules */
	struct io_node **input;
	struct io_node **output;
#ifdef __STDC__
	double (*andFcn)(double, double);
	double (*orFcn)(double, double);
	double (*impFcn)(double, double);
	double (*aggFcn)(double, double);
#else
	double (*andFcn)();
	double (*orFcn)();
	double (*impFcn)();
	double (*aggFcn)();
#endif
	double (*defuzzFcn)();
	double *BigOutMfMatrix;	/* used for Mamdani system only */
	double *BigWeightMatrix;/* used for Mamdani system only */
	double *mfs_of_rule;	/* MF values in a rule */
	struct fis_node *next;

	/* the following are for ANFIS only */
	int *in_mf_n;		/* number of input MF's */
	int total_in_mf_n;
	int *out_mf_n;		/* number of output MF's */
	int node_n;		/* number of nodes */
	int para_n;		/* number of parameters */
	double *para;		/* array of current parameters */
	double *trn_best_para;	/* best parameters for training */
	double *chk_best_para;	/* best parameters for checking */
	double *de_dp;		/* array of de_dp */
	double *do_dp;		/* array of do_dp */
	struct an_node **node;	/* array of node pointers */
	struct an_node *layer[7];/* array of pointers to each layer */
	int layer_size[7];	/* no. of nodes in a layer */

	int epoch_n;
	int actual_epoch_n;	/* epoch number when error goal is reached */

	/* training data */
	double **trn_data;
	int trn_data_n;
	double *trn_error;	/* array of error for each epoch */
	double min_trn_error;	/* min. error achieved by best parameters */
	double trn_error_goal;	/* error goal */

	/* checking data */
	double **chk_data;
	int chk_data_n;
	double *chk_error;	/* array of error for each epoch */
	double min_chk_error;	/* min. error achieved by best parameters */
	double chk_error_goal;	/* error goal, not used */

	/* step size of gradient descent */
	double *ss_array;	/* step size history */
	double ss;		/* current step size */
	double ss_dec_rate;	/* step size increase rate */
	double ss_inc_rate;	/* step size increase rate */
	int last_dec_ss;	/* ss is decreased recently at this epoch */
	int last_inc_ss;	/* ss is increased recently at this epoch */

	/* display options */
	int display_anfis_info;
	int display_error;
	int display_ss;
	int display_final_result;

	/* matrices for kalman filter algorithm */
	double lambda;		/* forgetting factor */
	double **tmp_node_output;/* for storing tmp node output */
	double *kalman_io_pair;	/* data pairs for kalman filter */
	double **kalman_para;	/* matrix for kalman parameters */
	/* the following are for kalman filter algorithm */
	double **S;
	double **P;
	double **a;
	double **b;
	double **a_t;
	double **b_t;
	double **tmp1;
	double **tmp2;
	double **tmp3;
	double **tmp4;
	double **tmp5;
	double **tmp6;
	double **tmp7;
	/* the following are for on-line ANFIS of SL */
	double **in_fismat;
	int m;
	int n;
} FIS;

typedef struct io_node {
	char name[STR_LEN];
	int mf_n;
	double bound[2];
	double value;
	struct mf_node **mf;
} IO;

typedef struct mf_node {
	char label[STR_LEN];
	char type[STR_LEN];
#ifdef __STDC__
	double (*mfFcn)(double, double *); /* pointer to a mem. fcn */ 
#else
	double (*mfFcn)(); /* pointer to a mem. fcn */ 
#endif
	double para[MF_PARA_N];
	double *sugeno_coef;	/* for Sugeno only */
	double value;		/* for Sugeno only */
	double *value_array;	/* for Mamdani only, array of MF values */
	int userDefined;	/* 1 if the MF is user-defined */
} MF;

/* node for adaptive networks */
typedef struct an_node {
	char *name;		/* input names, MF labels, etc. */
	char *type;		/* MF type */
	int index;		/* index within ANFIS */
	int l_index;		/* local index within layer */
	int ll_index;		/* local index within group (MF only) */
	int layer;		/* which layer */
	int para_n;		/* number of parameters */
	int fanin_n;		/* number of fan-in */
	struct fan_node *fanin;	/* array of fan-in nodes */
	int fanout_n;		/* number of fan-out */
	struct fan_node *fanout;/* array of fan-out nodes */
	double value;		/* node value */
	double de_do;		/* deriv. of error wrt node output */
	double tmp;		/* for holding temporary result */
	double (*nodeFcn)();	/* node function */
	double *input;		/* array of local input values */
	double *para;		/* pointer into parameter array */
	double *de_dp;		/* pointer into de_dp array */
	double *do_dp;		/* pointer into do_dp array */
	double bound[2];	/* bounds, for input/output nodes */
} NODE;

/* node for fan-in and fan-out list */
typedef struct fan_node {
	int index;		/* index of node */
	struct fan_node *next;	/* next FAN node */
} FAN;
