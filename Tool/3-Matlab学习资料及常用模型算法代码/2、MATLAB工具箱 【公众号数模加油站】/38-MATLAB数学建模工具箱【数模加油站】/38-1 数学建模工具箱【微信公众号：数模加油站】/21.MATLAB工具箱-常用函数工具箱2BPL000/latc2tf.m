function [num,den]=LATC2TF(K,V)
%LATC2TF Lattice filter to transfer function conversion.
%   [NUM,DEN] = LATC2TF(K,V) finds the transfer function numerator
%   NUM and denominator DEN from the IIR lattice coefficients K and
%   ladder coefficients V.
%
%   [NUM,DEN] = LATC2TF(K,'iir') assumes that K is associated with an
%   all-pole IIR lattice filter.
%
%   NUM = LATC2TF(K,'fir') and NUM = LATC2TF(K) find the transfer
%   function numerators from the FIR lattice coefficients specified by K.

% Reference: J.G. Proakis, D.G. Manolakis, Digital Signal Processing,
%            3rd ed., Prentice Hall, N.J., 1996, Chapter 7.
%
%   Author(s): D. Orofino, 5-6-93
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 1997/11/26 20:13:43 $

error(nargchk(1,2,nargin));

% Handle empty cases immediately:
if isempty(K) | ( (nargin>1) & ~isstr(V) & isempty(V) ),
  num=[]; den=[]; return
end
% Parse input args:
if nargin>1,
  if isstr(V),
    switch(lower(V))
    case 'iir'
      lattice_type = 1;  % IIR
      V=1;               % Default ladder coeff
    case 'fir'
      lattice_type = 0;  % FIR
    otherwise
      error('Lattice type must be ''fir'' or ''iir''.');
    end
  else
    lattice_type = 1;    % IIR
  end
else
  lattice_type = 0;      % FIR
end

% Handle FIR case:
if lattice_type == 0,
  num = rc2poly(K);
  den = 1;
  return;
end

% Solve for IIR lattice or lattice-ladder coefficients:
K=K(:); V=V(:);

% Make sure V is length(K)+1:
ordiff = length(V)-length(K)-1;
if ordiff>0,
  K = [K; zeros(ordiff,1)];
  % error('length(V) must be <= 1+length(K).');
elseif ordiff<0,
  V = [V; zeros(-ordiff,1)];
end

num = V(1);
den = K(1);
for m = 2:length(K)
  bm = conj(den(m-1:-1:1));
  den = [den+bm*K(m) K(m)];
  num = [V(m)*bm num];
end
den = [1 den];

% end of latc2tf.m
