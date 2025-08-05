function [K,V]=TF2LATC(num,den)
%TF2LATC Transfer function to lattice filter conversion.
%   [K,V] = TF2LATC(NUM,DEN) finds the lattice parameters K and the ladder
%   parameters V for an IIR (ARMA) lattice-ladder filter, normalized by
%   DEN(1).  Note that an error will be generated if any poles of the
%   transfer function lie on the unit circle.
%
%   K = TF2LATC(1,DEN) finds the lattice parameters K for an IIR
%   all-pole (AR) lattice filter.  [K,V] = TF2LATC(1,DEN) returns
%   a scalar ladder coefficient V.
%
%   K = TF2LATC(NUM) finds the lattice parameters K for an FIR (MA)
%   lattice filter, normalized by NUM(1).
%
%   See also LATC2TF, LATCFILT.

% Reference: J.G. Proakis, D.G. Manolakis, Digital Signal Processing,
%            3rd ed., Prentice Hall, N.J., 1996, Chapter 7.
%
%   Author(s): D. Orofino, 5-6-96
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 1997/11/26 20:12:52 $

% Convert an all-pole IIR model to lattice coefficients:
%            DEN = [1 13/24 5/8 1/3];
%            K = tf2latc(1,DEN);  % K will be [1/4 1/2 1/3]'
%

if isempty(num) | ( (nargin>1) & isempty(den) ),
  K=[]; V=[]; return
end
num = num(:);     % Force numerator polynomial into a column

if nargin==2,
  % Solve for IIR lattice or lattice-ladder coefficients:
  den = den(:);     % Force into a column
  if length(den)<2,
    % Only 1 denominator coeff, which we scale by, so the system
    % is really pure-FIR, and the corresponding ladder is simply
    % the numerator polynomial:
    K = 0;    % No non-zero reflection coefficients
    V = num;  % Ladder is numerator polynomial
    return
  end

  % Make sure num and den are the same length:
  ordiff = length(den)-length(num);
  if ordiff>=0,
    num = [num;zeros(ordiff,1)];
  else
    den = [den;zeros(-ordiff,1)];
  end
  M = length(den)-1;

  % Convert to lattice form recursively:
  Am = den./den(1);
  Cm = num;
  for m=M:-1:1,
    % Get coefficients:
    K(m) = Am(end);
    V(m) = Cm(end);
    % Check for stability:
    if abs(K(m))>=1,
      error('The IIR system is unstable.');
    end
    % Compute reduced polynomials:
    % Last entries are 0 if properly reduced
    Bm = conj(Am(end:-1:1));
    Cmm1 = Cm - V(m)*Bm;
    Amm1 = (Am - K(m)*Bm) / ( 1 - K(m)*conj(K(m)) );
    % Prepare for next iteration:
    Am = Amm1(1:end-1);
    Cm = Cmm1(1:end-1);
  end
  % Force lattice/ladder coefficients into columns:
  V=[Cm;V(:)];  % Grab last ladder coeff
  K=K(:);

else
  % Solve for FIR lattice coefficients:
  if nargout>1,
    error('Too many output arguments.');
  end
  if length(num)==1,
    K=0;
  else
    % K=poly2rc(num); K=K(:); return

    % Convert to lattice form recursively:
    M = length(num)-1;
    Am = num./num(1);
    for m=M:-1:1,
      % Get coefficients:
      K(m) = Am(end);
      if m==1, break; end
      % Check for stability:
      if abs(K(m))==1,
	error('The FIR system has a zero on the unit circle.');
      end
      % Compute reduced polynomials:
      % Last entries are 0 if properly reduced
      Bm = conj(Am(end:-1:1));
      Amm1 = (Am - K(m)*Bm) / ( 1 - K(m)*conj(K(m)) );
      % Prepare for next iteration:
      Am = Amm1(1:end-1);
    end
    % Force lattice coefficients into column:
    K=K(:);
  end
end

% end of tf2latc.m
