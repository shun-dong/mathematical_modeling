function [dm,out_vecs,out_mixing] = param_sep_2x (p, desc)
%
% Parametrization of a seprable state (alternate)
% Advantage: Simpler topology for searches & quicker
% Disadvantage: Required more parameters (144 instead of 79 for two qubits)
%
% Usage: [dm,out_vecs,out_mixing] = param_sep_1 (p<, desc>)
%     p            The parameters
%     desc         DM descriptor (optional for two qubits)
%     dm           Resulting separable dm
%     out_vecs     The separated vectors making up the separable states - a column for each state
%                  The vectors are specified one after the other in the column, 
%                  making it of size sum(desc).
%     out_mixing   The mixing of the above vectors
%
% See param_sep_1 for mathematical concept and references.
%
% Speed is achieved by inlining the param_p, param_sqrt_p, etc using an approach similar to 
% param_p_2x
%
% NOTES: 
% 1.  See "demo_reconstructing_param_sep" for insight into the 2nd and 3rd
%     output parameters
% 2.  There are parametrization subspaces for which the state would be NaN. 
%     One probable cause if the use of param_p_2x, which returns NaN for
%     all zero parameters.
%

if nargin == 1
    desc = [2 2];
    if length(p) ~= param_sep_2x_size(desc)
        error ('Parameters for param_sep_2x are the wrong length for the defaults [2 2] descriptor');
    end
end

pd = prod(desc);
pd2 = pd*pd;
sd = sum(desc);
n = length(desc);

all_pure_parts = NaNs(pd2, pd);
p_pure = sin(reshape(p(1:(pd2*sd)), pd2, sd).*2*pi); % Cyclical
p_phase = exp(i*reshape(p((pd2*sd+1):(pd2*sd*2)), pd2, sd)); % Naturally cyclical
p_mixing = sin(reshape(p((pd2*sd*2+1):(pd2*sd*2+pd2)), 1, pd2).*2*pi).^2; % Cyclical and semi-positive

p_mixing_norm = sum(p_mixing);
if is_close(p_mixing_norm,0)
    dm = NaNs(pd,pd);
    return;
end
p_mixing = p_mixing / p_mixing_norm;

p_pure = p_pure .* p_phase;

all_pure_parts(:,1:desc(1)) = p_pure(:,1:desc(1));
z =     desc(1);
q = 1 + desc(1);
for k=2:n
    zz = z*desc(k);
    qq = q + desc(k);
    for lin=1:pd2
        all_pure_parts(lin,1:zz) = kron(all_pure_parts(lin,1:z), p_pure(lin,q:(qq-1)));
    end
    z = zz;
    q = qq;
end

dm = zeros(pd,pd);
for k=1:pd2
    dm_part = transpose(all_pure_parts(k,:))*conj(all_pure_parts(k,:)); % Since it's a row vector
    dm = dm + (p_mixing(k)/trace(dm_part)) .* dm_part;
end

if nargout > 1
    out_mixing = p_mixing;
    out_vecs = NaNs(sd, pd2);
    for k=1:pd2
        pos = 1;
        for m=1:n
            pos2 = pos + desc(m);
            out_vecs(pos:(pos2-1),k) = p_pure(k,pos:(pos2-1));
            pos = pos2;
        end
    end
end

