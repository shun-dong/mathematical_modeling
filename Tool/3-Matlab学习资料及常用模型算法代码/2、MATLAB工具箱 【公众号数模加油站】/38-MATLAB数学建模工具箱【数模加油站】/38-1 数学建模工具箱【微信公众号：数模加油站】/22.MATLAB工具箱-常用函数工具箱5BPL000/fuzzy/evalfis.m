function [output_stack,IRR,ORR,ARR] = evalfis(input, fis, numofpoints);
% EVALFIS    Perform fuzzy inference calculations.
%   Synopsis
%   output= evalfis(input,fismat)
%   output= evalfis(input,fismat, numPts)
%   [output, IRR, ORR, ARR]= evalfis(input,fismat)
%   [output, IRR, ORR, ARR]= evalfis(input,fismat, numPts)
%   Description
%   evalfis has the following arguments:
%   input: a number or a matrix specifying input values. If input is an M-by-N
%   matrix, where N is number of input variables, then evalfis takes each row
%   of input as an input vector and returns the M-by-L matrix to the variable,
%   output, where each row is an output vector and L is the number of output
%   variables.
%   fismat: an FIS structure to be evaluated.
%   numPts: an optional argument which represents the number of sample points
%   on which to evaluate the membership functions over the input or output
%   range. If this argument is not used, the default value of 101 point is
%   used.
%   The range labels for evalfis are as follows:
%   output: the output matrix of size M-by-L, where M represents the number of
%   input values specified above, and L is the number of output variables for
%   the FIS.
%   The optional range variables for evalfis are only calculated when the input
%   argument is a row vector, (only one set of inputs is applied). These
%   optional range variables are:
%   IRR: the result of evaluating the input values through the membership
%   functions. This is a matrix of size numRules-by-N, where numRules is the
%   number of rules, and N is the number of input variables.
%   ORR: the result of evaluating the output values through the membership
%   functions. This is a matrix of size numPts-by-numRules*L, where numRules is
%   the number of rules, and L is the number of outputs. The first numRules
%   columns of this matrix correspond to the first output, the next numRules
%   columns of this matrix correspond to the second output, and so forth.
%   ARR: the numPts-by-L matrix of the aggregate values sampled at numPts
%   alongthe output range for each output.
%   When invoked with only one range variable, this function computes the
%   output vector output of the fuzzy inference system specified by the matrix
%   fismat for the input value specified by the number or matrix, input. This
%   computation is The optional argument
%   Example
%   fismat = readfis('tipper');
%   out = evalfis([2 1; 4 9],fismat)
%   This generates the response
%   out =
%   	7.0169
%   	19.6810
%   See Also
%   ruleview, gensurf

%   Kelly Liu, 10-10-97.
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 1997/12/01 21:44:48 $

if nargin<2
  disp('Need at least two inputs');
  output_stack=[];
  IRR=[];
  ORR=[];
  ARR=[];
  return;
elseif nargin ==2
  [output_stack,IRR,ORR,ARR]=evalfismex(input, fis, 101);
else
  [output_stack,IRR,ORR,ARR]=evalfismex(input, fis, numofpoints);
end

