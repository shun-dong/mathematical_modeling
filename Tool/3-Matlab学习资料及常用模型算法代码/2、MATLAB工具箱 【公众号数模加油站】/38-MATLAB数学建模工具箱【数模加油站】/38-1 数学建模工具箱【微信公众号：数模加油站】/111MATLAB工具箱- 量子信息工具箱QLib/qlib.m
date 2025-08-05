%
% QLIB - Quantum Information computation library
%
% (c) Shai Machnes 2006-2007, Quantum Information and Foundations Group, Tel-Aviv University
% email: machness at post.tau.ac.il
%
% All computer programs/code/scripts are released under the terms of the 
% GNU Lesser General Public License 3.x, except where explicitly 
% stated otherwise. Everything else (documentation, algorithms, etc) is 
% licensed under the Creative Commons Attribution-Share Alike 2.5 License
% (see "LICENSE.txt" for details). 
%
% For the latest version, visit http://www.qlib.info
%
% Usage:
%     addpath(genpath('path of qlib')); 
%     qlib;
%
% For help on a specific function, simply type: "help funcname"
%
% Entities:
%
%     DM/pure descriptor:
%         A vector specifying the particle degrees of freedom (DoF).
%         For example, a qubit, qutrite, qubit would be [2,3,2]
%         Bits are named with capital letters: ABC, ... (Alice, Bob, Charlie, ...)
%         Values are 0, 1, 2, 3, ...
%
%     Name descriptor:
%         An cell-array specifying the names for the "particles".
%         Default is {'A','B','C',...}
%
%     Pure state:
%         A column vector of complex numbers. Length: prod(desc). 
%         Ordering of elements is with A being the most significant digit. 
%         For example, given a state with descriptor [3 2], A=0,1,2 and B=0,1, 
%         then the order of elements in the column is (left to right) 
%         00, 01, 10, 11, 20, 21 with A being the left-most/most 
%         significant digit.
%
%     Density matrix:
%         A complex (Hermitian) matrix of prod(desc)^2 elements. 
%         Row/Column ordering is as for the pure state.
%
%     CPD - Classical Probability Distribution
%         Similar in structure to a pure state, except all numbers are
%         real.
%
%     Tensor structures: Re-arrangement of elements in "normal" multi-particle structures 
%         to allow easier access. 
%
%         Pure state/classical probability distribution tensor:
%             Instead of a linear vector, data is stored in a tensor with
%             one dimension per particle: (A_index, B_index, C_index, ...)
%     
%         Density tensor:
%             For three particles / 3 DoF, the DM elements will be arranged
%             with six indexes: (A_ket,A_bra,B_ket,B_bra,C_ket,C_bra), with "ket" being the
%             DM's row number and "bra" the column.
%
%         Note that all operations are performed on the "normal" representation.
%
%     Bipartition mask:
%          A vector, the same length as the descriptor, with "0" for one
%          side of the partition and "1" for the other
%
% Function list:
%
%     DM, pure states and CPDs / General 
%         comm, a_comm      Matrix (anti) commutation
%         validate_dm       Make sure a matrix describes a good DM. If yes, return unchanged. If not, issue an error
%         validate_pure     Make sure a vector describes a good pure state. If yes, return unchanged. If not, issue an error
%         validate_cpd      Make sure a vector describes a good cpd. If yes, return unchanged. If not, issue an error
%         is_dm_valid       Is the matrix a DM?
%         is_pure_valid     Is the vector a proper pure state?
%         is_cpd_valid      Is the vector a proper CPD?
%         gen_desc          Generate a descriptor assuming all qubits (2^N)
%         gen_name_desc     Generate the default name descriptor
%         no_global_phase   Remove global phase from a pure state
%         is_pure           Does the DM represent a pure state?
%         normalize_pure    Normalize a pure state
%         cannonize_pure    Set the global phase of a pure state to 1 (i.e. make the first non-zero element real)
%         normalize_classical Normalize a classical probability distribution
%         normalize_dm      Normalize a density matrix to have trace 1
%         is_product        Is the DM/pure a product of the single-density DMs?
%         all_masks         Generate masks for all partitions of a set of particles
%         all_bipartition_masks Generate all bipartition masks 
%         Schmidt_decompo   Find the Schmidt decomposition (coefficient and base) for a pure state
%         trace_norm        Compute the trace norm of a matrix
%         pure_norm         Find the norm of a pure state (should be 1)
%         dephase_pure      Fix the global phase of a pure state to 0 (real)
%         prod_SU_gen       Find all products of the SU(desc(k)) generators
%         exp_rep_for_unitary_op       Exponential representation for unitary operator (using prod_SU_gen)
%       
%     DM and pure states / Distance
%         dist_trace        The trace distance 
%         dist_KL           Compute the Kullback-Leibler "distance" between two density matrices
%         dist_KL_CPD       Compute the Kullback-Leibler "distance" between two CPDs
%         dist_Bures        Compute the Bures distance between two density matrices
%         dist_Bures_angle  Compute the Bures angle between two density matrices
%         dist_Fubini_Study The Fubini-Study metric for two pure states
%         dist_Hilbert_Schmidt Compute the Hilbert Schmidt distance (i.e. sqrt of inner product) between two density matrices
%         Hilbert_Schmidt_norm Compute the Hilbert-Schmidt norm between two elements, abs(<A,B>), with abs(X) == sqrt(X'*X)
%         fidelity          Fidelity between two DMs
%
%     DM and pure states / Shape shifting
%         pure2dm           Convert a pure state to a density matrix
%         dm2pure           Convert a DM representing a pure state to a state-vector
%         dm2tensor         Transforms a density matrix into a density tensor
%         tensor2dm         Transforms a density tensor to a density matrix
%         partial_trace     Trace out any number of DoF from a DM
%         partial_trace_pure Trace out any number of DoF from a pure state
%         partial_trace_cpd Trace out any number of DoF from a CPD
%         permute_dof_dm    Permute DoF of a DM
%         permute_dof_pure  Permute DoF of a pure state
%         ipermute_dof_dm   Inverse-permute DoF of a DM
%         ipermute_dof_pure Inverse-permute DoF of a pure state
%         partial_transpose Transpose any subset of particles
%         classical2dm      Convert a classical distribution vector to a DM
%         dm2classical      Convert a DM to a classical distribution vector
%         pure2tensor       Convert a pure state or classical distribution vectors to a tensor
%         tensor2pure       Convert a tensor to a pure state or classical distribution vectors
%         reorder_and_merge_dm_dims    Reorder and/or merge DoF in a DM
%         reorder_and_merge_pure_dims  Reorder and/or merge DoF in a pure state
%         purify_compact    Purify a mixed state using the minimal number of DoF possible
%         purify_full       Purify a mixed state using the same no. of DoF as in the original state
% 
%     DM and pure states / "Famous" states
%         GHZ               Generate a (generalized) GHZ state
%         W101              Generate a (generalized) W state
%         Werner            Generate a (generalized) Werner state
%         Gisin             Generate the Gisin state
%         rho3              Generate the rho3 state
%         Note: Bell states are provided as constants. See below.
%
%     DM and pure states / Gates
%         Deutsch_gate      The Deutsch gate (for pi/2 this is the Toffoli gate)
%         control_gate      Activate a operation if the control bit is 1
%         swap_gate         Swap gate of arbitrary dimension
%         cnot_gate         The generalized CNOT gate - cyclically permutes the basis vectors
%
%     DM and pure states / Majorization
%         is_majorized_by                  Tests majorization of the first DM by the second
%         is_weakly_majorized_by           Tests weak majorization of the first DM by the second
%         is_super_majorized_by            Tests super-majorization of the first DM by the second
%         is_majorizationally_incompatible Tests for incompatibility
%         majorization_vector (internal)   Extract the majorization vector from a dM
%
%     Entropy and Entanglement / Entanglement
%         concurrence               Compute the concurrence of a 2-qubit DM
%         concurrence_pure          Compute the concurrence of a 2-qubit pure state
%         entanglement_of_formation Compute the entanglement of formation for a two qubit state
%         entanglement              The entanglement of a given bipartition of a pure state
%         logarithmic_negativity    Compute the logarithmic negativity of a DM
%         is_entangled_pt           Peres-Horodecki entanglement witness (yes/no/don't-know) for a given bipartition of a DM
%         is_entangled_all_pt       Peres-Horodecki entanglement witness for all bipartition of a DM (is there any entanglement in a state)
%         negativity                Compute the negativity of a DM
%         relative_entanglement     Relative entanglement (minimal KL distance to a separable state)
%         robustness_pure           The robustness of a pure state (minimal mixing with random state to be separable)
%         singlet_fraction    Compute (by searching for) the (generalized) singlet fraction for any given bipartition of any DM
%         schmidt_number            The number of non-zero schmidt coefficients
%         tangle                    Compute the tangle (for 3-qubit pure state or 2-qubit DM)
%
%     Entropy and Entanglement / Entropy and mixedness
%         H_Shannon                 Shannon entropy
%         S_Von_Neumann             Von-Neumann entropy
%         SvN2                      Compute the Von-neumann entropy for [p 1-p]
%         linear_entropy            Compute the linear entropy of a given density matrix
%         relative_entropy          Relative entanglement (minimal KL distance to a product state)
%         participation_ratio       Estimate of the effective number of states in the mixture
%         purity                    The purity (measure of mixingness) of a given density matrix
%
%     Entropy and Entanglement / Mutual information
%         mutual_info_dm            Mutual information for a given bipartition of a DM
%         mutual_info_pure          Mutual information for a given bipartition of a pure
%         mutual_info_cpd           Mutual information for a given bipartition of a CPD
%
%
%     Measurements
%         act_on                    Act with an operator on some of the DoF of a system
%         expand_op                 Expand / reorder DoF in an operator to fit the entire system
%         measure                   Perform a measurement on a (sub)system, returning the resulting mixed state
%         collapse                  Compute the various collapsed "universes" and their probabilities when measuring a system
%         weak_measurement          Compute the real part of a weakly measured value
%
%     Measurements / POVM
%         is_Krauss_set_valid       Check if you have a complete valid set of Krauss operators (boolean function)
%         validate_Krauss_set       Validate you have a complete valid set of Krauss operators (error if not)
%         complete_Krauss_set       Complete a Krauss set to unity
%         collapse_povm             Perform a generalized measurement using a set of Krauss operators
%
%
%     Parameterizations (pure states, DMs, matrix classes, etc)
%         Useful for searches of various spaces and for generation of random objects.
%         Naming convention:
%             * Often more than one parameterization is implemented. 
%               The functions will be called param_XXX_1, param_XXX_2, ...
%             * If a parameterization requires more parameters than is strictly required, 
%               the numeral will be followed by x, such as param_sep_2x.
%               This is often done for speed and/or to simplify the topology for searches.
%             * To find the number of parameters required, call param_XXX_n_size
%             * To generate a random object, 
%         Parameter range:
%             The parameters are usually in a cyclic space, often (0..1)^M
%         Parameter structure:
%             A row vector
%         Random object:
%             Use: param_XXX_rand(desc), which is equivalent to param_XXX(1000*randrow(param_XXX_size(desc)),...)
%
%         param_p_1,2x,3    Classical probability distribution (CPD) parameterization
%         param_p_1,2x,3_sqrt Parameterization for square root of param_p_1,2x,3
%         param_pure_1,2x   Parametrize a pure state
%         param_dm,_2x      Density matrix parameterization
%         param_sep_1,2x    separable DM parameterization
%         param_prod        Product DM parameterization
%         param_prod_pure   Product pure state parameterization
%         param_prod_cpd    Product CPD parameterization
%         param_H_1,2       Hermitian matrix parameterization 
%         fully_entangled_state    Parameterization of a fully entangled bi-partite state with 2N DoF
%
%     Parameterizations / SU, U
%         param_SU_1        Parameterization of SU(N)
%         param_SU_2        Alternate form of SU(N) parameterization
%         param_U_1         Parameterization of U(N)
%         param_U_2         Alternate form of U(N) parameterization
%         param_SU_over_U   Parameterization of SU(N) without the phase-per-column redundancy
%         SU_gen_cache      Caches various calculations having to do with the SU group and it's
%         calc_SU_gen       (internal) Calculates the generators of SU(N), in the fundamental (NxN) representation
%         SU_param_form     (internal) Compute which generators to utilize in the param_SU parameterization
%         prod_SU_gens      Internal use: Get the generators for an U(prod(desc)) built from generators of U(desc(k)) as U_ijk... = kron(U(desc(1))_i, kron (U(desc(2))_j, ...
%         prod_SU_gens_desc Internal function, for use by prod_SU_gens. Converts a state descriptor to a name which can serve as a key in QLib.prod_gen.<the_key>.... allowing prod_SU_gens to cache results.
%
%
%     Geometry:
%         theta_phi_from_spin        Direction of a given spinor
%         spin_at_theta_phi          Spinor at requested direction
%         sigma_at_theta_phi         A sigma matrix for a given 3D direction
%         unitvec_from_theta_phi     Compute the unit vector for a given angle
%         theta_phi_from_unitvec     Extract (theta, phi) from a unit vector
%         unitvec_ortho_to_unitvec   Create a unit vector orthogonal to a given unit vector
%         spin_rotation_matrix       The matrix rotating FROM a given direction TO the z basis
%
%
%     Utility / Search - Look for an extrema of a function in it's parameter space or find the place where is reaches a certain value
%         fmaxsearch        A complementary routine for Matlab's fminsearch
%         fmaxunc           A complementary routine for Matlab's fminunc
%         fmin_anneal       Simulated annealing search for a global minima
%         fmax_anneal       Complementary to the above
%         fmin_anneal_opt   Option settings for fmin/fmax_anneal
%         fmin_combo        A combined search function utilizing both fminsearch and simulated annealing, alternatively
%                           it can locate the place in param-space where a goal value is reached
%         fmax_combo        Complementary to the above
%         fmin_combo_opt    Option setting for fmin/fmax_combo
%
%    Utility / metrics
%         Euclidean         Returns the Euclidean distance between two vectors
%         Manhattan         Returns Manhattan distance (sum of differences) between two vectors
%         Chebyshev         Returns Chebyshev distance (max of differences) between two vectors
%
%     Utility / Math
%         steps             Generate a vector with a given number of equally spaced points
%         randrow           Generate a row of random numbers
%         irand             Generate integer random numbers in a given range
%         vrand             Choose an element at random given a vector of element probabilities
%         rand_direction    Generates a uniform distribution of points on the surface of a sphere
%         mminn,mmaxx       Global minimum/maximum over all matrix elements (arbitrary dim)
%         ssumm             Global summation
%         frac              The fractional part
%         clip              clip all elements to a given range
%         bilinear_interp   Given a grid of values for a 2D function, compute additional points using bilinear interpolation
%         is_nice           Is it a "normal" number (not NaN of Inf)?
%         is_eql            Compare matrices  NaN ~= NaN, same as build-in isequal
%         is_eql_2          Compare matrices, NaN == NaN
%         is_close          Compare two values (scalar or matrix) up to "QLib.close_enough" accuracy
%         is_close_2        Same as above, except NaNs are close to each other as are equal-signed Infs
%         cleanup           Heuristic clean-up of values (almost integers are rounded, almost reals almost imaginary are "treated")
%         mat_scale         Find the scale factor between two matrices or NaN if it doesn't exist
%         NaNs              Similar to "zeros", except it returns NaNs
%         all_perm          Generate all unique permutations of a given data
%         all_perm_by_count As above, with data given as values and number of repetitions
%         mat_abs           Absolute value of (any) normal matrix
%         yn3_and/or        3-way logic (yes/no/don't-know). Useful for combining witness functions
%         log_quiet         Natural logarithm returning -Inf for 0
%         p_log2_p          Compute -p*log_2 (p), returning 0 for p==0
%         is_Hermitian      Is a matrix Hermitian? (or close_enough
%         is_Unitary        Is a matrix unitary? (or close_enough
%         is_normal_matrix  Is this matrix a normal matrix (A*A' == A'*A)? 
%         is_pos_semidef    Is this matrix positive semi-definite?
%         direct_sum        The direct sum of any number of matrices
%         kron2             Kron any number of matrices
%         epsilon_tensor    Compute the epsilon anti-symmetric tensor to any given degree
%         are_these_linearly_independent Are these vectors/matrices/tensors linearly independent?
%         gram_schmidt      Transform a set of objects (vectors, matrices, tensors) into an orthonormal set using the Gram Schmidt process
%         gram_schmidt_t    A gram_schmidt process, but in this version the calculation done by a diagonalization technique. This results in "nicer" vectors, with more zeros
%         find_span         Decompose an object as linear sum of objects of same dimensionality
%         span              Reconstructs a decompose an object as linear sum of objects of same dimensionality
%         jordanFix         There is a bug in Matlab's "jordan" - the maple eval does not go through
%         jordan2           Jordan decomposition, returning the list of blocks (eigenvalues) as three-column matrix
%         jordan3           A refined jordan2, with sorting of eigenvalues & Gram-Schmidt where applicable
%         eig2              A variant of "eig" with sorted & normalized eigenvectors
%         smooth_ma         Smoothed moving average
%         smooth_min        Smoothed minimum using a moving window
%         mat2sun           Convert a matrix (DM, unitary or Hermitian) to the kron(SU(desc(1)), SU(desc(2)), ...) basis
%         sun2mat           Convert a matrix (DM, unitary or Hermitian) from the kron(SU(desc(1)), SU(desc(2)), ...) basis to the normal representation
%
%     Utility / General
%         format_delta_t    Format a period of time supplied in seconds as an easy-to-read string
%         gen_all_idxs      A list of indexes into all elements of a multidimensional tensor
%         num2mask          Convert a number to a mask
%         permute_1D_cell_array      Permute a 1D cell array
%         runstamp          Print the script/function being executed, and the time it was run
%         sub3ind           A version of sub2ind accepting the individual indexes as an array
%         to_row, to_col    Convert anything to a row/column vector
%         to_square         Convert a vector to a square matrix of sqrt(length(v))^2 elements
%         unique2           Find unique values in an array and the number of times they appear
%         iff               State a condition as a function call (similar to the C language "?" operator)
%         swap              Swap values without resorting to a temporary variable
%         RatMat            Convert a matrix to symbolic form (fix for Matlab's sym)
%         doubleFixMatlabRootOfBug          Fix a Matlab bug in the "double" function converting a symbolic matrix from Maple         
%         print_matrix_for_mathematica      Convert a Matlab matrix to a format you can copy & paste into Mathematica
%
%     Utility / Graphics
%         draw2d_func       Draw a 1d function in 2d of a given function
%         draw3d_func       Draw a 2d function in 3d of a given function
%         draw_hist         Draw a histogram of the values returned by a given function 
%         set_x/y/z_axis    Force axis limits on graphs
%         save_current_plot Saves the current plot in 3 formats - PNG, EPS and FIG
%
%
%     Demos
%         demo_werner_measures
%             Subject: Basic example, Measures
%             Plot various measures of the entanglement within a Werner state
%         demo_Werner_measures
%             Subject: Basic example, measures
%             Plot multiple entanglement and entropy measures for the Werner states
%         demo_negativity_scale
%             Subjects: Basic example, Negativity, GHZ, partial states
%             Show the scaling of the negativity for a division an "n of M" bipartition of the GHZ state
%
%         demo_check_entropy_measure_additivity
%             Subject: Basic example, Parameterization, Measures
%             Check the additivity of any entropy measure 
%         demo_fidelity_vs_dist_trace
%             Subject: Basic example, Measures, Parameterizations
%             Show the relationship between fidelity and trace distance for a pair of randomly chosen pure states & DMs
%         demo_dist_measures
%             Subject: Basic example, Measures, Parameterizations
%             Examine how different DM distance measures relate to each other for random density matrices of various sizes
%         demo_test_distance_measure
%             Subject: Basic example, Parameterization, Measures
%             Is a given function a good distance measure?
%             You specify the function, and the program tests the measure for the various required properties.
%         demo_dense_coding
%             Subject: Basic example, Measurements
%             Step-by-step implementation of dense coding%         
%         demo_teleportation
%             Subject: Basic example, Measurements
%             Step-by-step implementation of teleportation
%
%         demo_show_SU_decompositions
%             Subjects: SU(N)
%             Is a sum of matrices from SU(n) x SU(m) equivalent to SU(n*m)?
%         demo_SU_comm
%             Subjects: SU(N)
%             Compute the SU(N) commutation relations in terms of SU(N) elements
%         demo_SU_param_equiv       
%             Subjects: searches, parmatrizations of SU(N)
%             Check equivalence between the two Parameterizations of SU(N)
%         demo_check_SU_over_U_does_span
%             Subjects: SU(N) algebra
%             Show that the diagonal SU(N) generators, together with I, 
%             span the diagonal matrices
%         demo_factoring_of_dm
%             Subjects: SU(N), linear algebra, multipartite DMs
%             Decompose a density matrix into a sum of SU generators.
%             For example: singlet = 1/4* (1 - sx*sx - sy*sy - sz*sz)
%         demo_log_mat_and_prod_gens_for_exponent_decomp
%             Subjects: matrix exponentiation, linear algebra, multipartite DMs, SU(N)
%             Decompose a unitary operator into expm(sum of SU(N) krons)
%             For example: CNOT = expm i*pi/4*(sz*sx-sz*I-I*sx+I)
%
%         demo_reconstructing_param_sep
%             Subjects: Parameterizations, searches, separable states
%             Given a state, find the closest separable state, and display
%             the parameterization
%             in human-readable form
%             
%
%     Global variables: All are under QLib.*, created at time of package initialization.
%         close_enough      Accuracy limit for the various numerics (such as is_close)
%         sigma.*           Spin half states
%             x,y,z,I 
%         Singlet           The cannonical psi_minus (00-11)/sqrt(2).
%         Bell.*                 
%             psi_plus, psi_minus, phi_plus, phi_minus
%         GHZ               Guess
%         gates
%             CNOT, cpahse, Hadamard, swap, Toffoli
%         eps{n}            The anti-symmetric tensors, generated by epsilon_tensor
%         SU{n}             A structure containing the generators and other info. See SU_gen_cache for details
%         base_path         Path under which the qlib package currently resides
%         Version           QLib version number
%
%     Help is available for each function
%
% Notes:
% *  A "clear" command may accidentally delete the QLib global variable. If this happens, just re-type "qlib".
% 

clc

% Find base path
fullpath = mfilename('fullpath');
p1 = find (fullpath == int32('/')); p2 = find (fullpath == int32('\')); mx = max([p1 p2]);  
basepath = fullpath (1:mx); clear p1 p2 mx fullpath;

clear QLib; clear global QLib; clear QLib; clear global QLib;
global QLib;

QLib.base_path = basepath; clear basepath;
QLib.Version = '1.0';
 
addpath(genpath(QLib.base_path)); 

qlib_init;

disp (' ');
disp (sprintf('QLIB - Quantum Information computation library, v%s', QLib.Version));
disp (' ');
disp (' ');
disp ('(c) Shai Machnes 2006-2007, Quantum Information and Foundations Group, Tel-Aviv University');
disp ('email: machness at post.tau.ac.il');
disp (' ');
disp ('All computer programs/code/scripts are released under the terms of the GNU Lesser General Public License 3.x, except where explicitly stated otherwise. Everything else (documentation, algorithms, etc) is licensed under the Creative Commons Attribution-Share Alike 2.5 License (see "LICENSE.txt" for details)');
disp ('  ');
disp ('If you use QLib in your research, please add an attribution in the form of the following reference: S. Machnes, quant-ph/0708.0478');
disp ('For the latest version, guides and information, visit http://www.qlib.info');
disp ('Type "help qlib" for intro and a list of functions.'); 
disp ('  ');
disp ('QLIB initialized successfully.');
disp ('   ');
drawnow;

