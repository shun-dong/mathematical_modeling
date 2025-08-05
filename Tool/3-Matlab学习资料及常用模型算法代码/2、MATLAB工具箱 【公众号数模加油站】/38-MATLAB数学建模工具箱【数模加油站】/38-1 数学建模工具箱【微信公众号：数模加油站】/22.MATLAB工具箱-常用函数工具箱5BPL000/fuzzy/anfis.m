function [t_fismat, t_error, stepsize, c_fismat, c_error] ...
    = anfis(trn_data, in_fismat, t_opt, d_opt, chk_data, method)
%ANFIS   Training routine for Sugeno-type FIS (MEX only).
%   Synopsis
%   [fismat,error1,stepsize] = anfis(trnData)
%   [fismat,error1,stepsize] = anfis(trnData,fismat)
%   [fismat1,error1,stepsize] = ...
%   anfis(trnData,fismat,trnOpt,dispOpt)
%   [fismat1,error1,stepsize,fismat2,error2] = ...
%   anfis(trnData,trnOpt,dispOpt,chkData)
%   [fismat1,error1,stepsize,fismat2,error2] = ...
%   anfis(trnData,trnOpt,dispOpt,chkData,optMethod)
%   
%   Description
%   This is the major training routine for Sugeno-type fuzzy inference systems.
%   anfis uses a hybrid learning algorithm to identify parameters of
%   Sugeno-type fuzzy inference systems. It applies a combination of the
%   least-squares method and the backpropagation gradient descent method for
%   training FIS membership function parameters to emulate a given training
%   data set. anfis can also be invoked using an optional argument for model
%   validation. The type of model validation that takes place with this option
%   is a checking for model overfitting, and the argument is a data set called
%   the checking data set.
%   The arguments in the above description for anfis are as follows:
%   trnData: the name of a training data set. This is a matrix with all but the
%   last column containing input data, while the last column contains a single
%   vector of output data.
%   fismat: the name of an FIS, (fuzzy inference system) used to provide anfis
%   with an initial set of membership functions for training. Without this
%   option, anfis will use genfis1 to implement a default initial FIS for
%   training. This default FIS will have two membership functions of the
%   Gaussian type, when invoked with only one argument. If fismat is provided
%   as a single number (or a vector), it is taken as the number of membership
%   functions (or the vector whose entries are the respective numbers of
%   membership functions associated with each respective input, when these
%   numbers differ for each input). In this case, both  arguments of anfis are
%   passed to genfis1 to generate a valid FIS matrix before starting the
%   training process.
%   trnOpt: vector of training options. When any training option is entered as
%   NaN the default options will be in force. These options are as follows:
%   trnOpt(1): training epoch number (default: 10)
%   trnOpt(2): training error goal (default: 0)
%   trnOpt(3): initial step size (default: 0.01)
%   trnOpt(4): step size decrease rate (default: 0.9)
%   trnOpt(5): step size increase rate (default: 1.1)
%   dispOpt: vector of display options that specify what message to display in
%   the MATLAB command window during training. The default value for any
%   display option is 1, which means the corresponding information is
%   displayed. A 0 means the corresponding information is not displayed on the
%   screen. When any display option is entered as NaN, the default options will
%   be in force. These options are as follows:
%   dispOpt(1): ANFIS information, such as numbers of input and output
%   membership functions, and so on (default: 1)
%   dispOpt(2): error (default: 1)
%   dispOpt(3): step size at each parameter update (default: 1)
%   dispOpt(4): final results (default: 1)
%   chkData: the name of an optional checking data set for overfitting model
%   validation. This data set is a matrix in the same format as the training
%   data set.
%   optMethod: optional optimization method used in membership function
%   parameter training: either 1 for the hybrid method or 0 for the
%   backpropagation method. The default method is the hybrid method, which is a
%   combination of least squares estimation with backpropagation. The default
%   method is invoked whenever the entry for this argument is anything but 0.
%   The training process stops whenever the designated epoch number is reached
%   or the training error goal is achieved.
%   Note on anfis arguments:
%   When anfis is invoked with two or more arguments, any optional arguments
%   will take on their default values if they are entered as NaNs or empty
%   matrices. Default values can be changed directly by modifying the file
%   anfis.m. NaNs or empty matrices must be used as place-holders for variables
%   if you don’t want to specify them, but do want to specify succeeding
%   arguments, for example, when you implement the checking data option of
%   anfis.
%   The range variables in the above description for anfis are as follows:
%   fismat1 is the FIS structure whose parametes are set according to a minimum
%   training error criterion.
%   error1 or error2 is an array of root mean squared errors, representing the
%   training data error signal and the checking data error signal,
%   respectively.
%   stepsize is an array of step sizes. The step size is decreased (by
%   multiplying it with the component of the training option corresponding to
%   the step size decrease rate) if the error measure undergoes two consecutive
%   combinations of an increase followed by a decrease. The step size is
%   increased (by multiplying it with the increase rate) if the error measure
%   undergoes four consecutive decreases.
%   fismat2 is the FIS structure whose parametes are set according to a minimum
%   checking error criterion.
%   Example
%   x = (0:0.1:10)';
%   y = sin(2*x)./exp(x/5);
%   trnData = [x y];
%   numMFs = 5;
%   mfType = 'gbellmf';
%   epoch_n = 20;
%   in_fismat = genfis1(trnData,numMFs,mfType);
%   out_fismat = anfis(trnData,in_fismat,20);
%   plot(x,y,x,evalfis(x,out_fismat));
%   legend('Training Data','ANFIS Output');
%   See Also
%   genfis1, anfis
%   References
%   Jang, J.-S. R., “Fuzzy Modeling Using Generalized Neural Networks and
%   Kalman Filter Algorithm,” Proc. of the Ninth National Conf. on Artificial
%   Intelligence (AAAI-91), pp. 762-767, July 1991.
%   Jang, J.-S. R., “ANFIS: Adaptive-Network-based Fuzzy Inference Systems,”
%   IEEE Transactions on Systems, Man, and Cybernetics, Vol. 23, No. 3, pp.
%   665-685, May 1993.%

%   Roger Jang, 9-12-94.  Kelly Liu, 10-10-97
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.22 $  $Date: 1997/12/01 21:44:39 $

if nargin > 6 & nargin < 1,
    error('Too many or too few input arguments!');
end

% Change the following to set default train options.
default_t_opt = [10;    % training epoch number
        0;  % training error goal
        0.01;   % initial step size
        0.9;    % step size decrease rate
        1.1];   % step size increase rate

% Change the following to set default display options.
default_d_opt = [1; % display ANFIS information
        1;  % display error measure
        1;  % display step size
        1]; % display final result
default_d_opt =[ 0; 0; 0; 0];
% Change the following to set default MF type and numbers
default_mf_type = 'gbellmf';    % default MF type
default_outmf_type='linear';
default_mf_number = 2;
if nargin <= 5,
    method = 1;
end
if nargin <= 4,
    chk_data = [];
end
if nargin <= 3,
    d_opt = default_d_opt;
end
if nargin <= 2,
    t_opt = default_t_opt;
end
if nargin <= 1,
    in_fismat = default_mf_number;
end

% If fismat, d_opt or t_opt are nan's or []'s, replace them with default settings
if isempty(in_fismat)
   in_fismat = default_mf_number;
elseif ~isstruct(in_fismat) & length(in_fismat) == 1 & isnan(in_fismat),
   in_fismat = default_mf_number;
end 
if isempty(t_opt),
    t_opt = default_t_opt;
elseif length(t_opt) == 1 & isnan(t_opt),
    t_opt = default_t_opt;
end
if isempty(d_opt),
    d_opt = default_d_opt;
elseif length(d_opt) == 1 & isnan(d_opt),
    d_opt = default_d_opt;
end
if isempty(method)
   method = 1;
elseif length(method) == 1 & isnan(method),
   method = 1;
elseif method>1 |method<0
   method =1;
end 
% If d_opt or t_opt is not fully specified, pad it with default values. 
if length(t_opt) < 5,
    tmp = default_t_opt;
    tmp(1:length(t_opt)) = t_opt;
    t_opt = tmp;
end
if length(d_opt) < 5,
    tmp = default_d_opt;
    tmp(1:length(d_opt)) = d_opt;
    d_opt = tmp;
end

% If entries of d_opt or t_opt are nan's, replace them with default settings
nan_index = find(isnan(d_opt)==1);
d_opt(nan_index) = default_d_opt(nan_index);
nan_index = find(isnan(t_opt)==1);
t_opt(nan_index) = default_t_opt(nan_index);

% Generate FIS matrix if necessary
% in_fismat is a single number or a vector 
if class(in_fismat) ~= 'struct',
    in_fismat = genfis1(trn_data, in_fismat, default_mf_type);
end

% More input/output argument checking
if nargin <= 4 & nargout > 3,
    error('Too many output arguments!');
end
if length(t_opt) ~= 5,
    error('Wrong length of t_opt!');
end
if length(d_opt) ~= 4,
    error('Wrong length of d_opt!');
end

% Start the real thing!
if nargout == 0,
    anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 1,
    [t_fismat] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 2,
    [t_fismat, t_error] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 3,
    [t_fismat, t_error, stepsize] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 4,
    [t_fismat, t_error, stepsize, c_fismat] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 5,
    [t_fismat, t_error, stepsize, c_fismat, c_error] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
else
    error('Too many output arguments!');
end
