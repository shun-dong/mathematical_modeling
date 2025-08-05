function [dm,out_vecs,out_mixing] = param_sep_1 (p, desc, param_p_func, param_p_size_func, param_pure_func, param_pure_size_func)
%
% Parametrization of a seprable state
%
% Usage 1: [dm,out_vecs,out_mixing] = param_sep_1 (p<, desc>)
%
% Usage: [dm,out_vecs,out_mixing] = param_sep_1 (p, <desc <, ...
%                                                param_p_func, param_p_size_func, ...
%                                                param_pure_func, param_pure_size_func>>)
%     p            The parameters
%     desc         DM descriptor (optional for two qubits)
%     param_p_func, param_p_size_func: Specifies the param_p_* functions
%                  used to compute the mixing of the pure product states
%                  Default: @param_p_1, @param_p_1_size
%     param_pure_func, param_pure_size_func: Specifies the param_pure_* functions
%                  used to compute the pure states
%                  Default: @param_pure_1, @param_pure_1_size
%
%     dm           Resulting separable dm
%     out_vecs     The separated vectors making up the separable states - a column for each state
%                  The vectors are specified one after the other in the column, 
%                  making it of size sum(desc).
%     out_mixing   The mixing of the above vectors
%
% The parametrization concept is based on the Caratheodory theorem and the 
% reference below which indicate that any seprable state is representable by 
% a sum of at most prod(desc)^2 single-particle projection operator
%
%
% NOTES: 
% 1.  See "demo_reconstructing_param_sep" for insight into the 2nd and 3rd
%     output parameters
% 2.  There are parametrization subspaces for which the state would be NaN. 
%     One probable cause if the use of param_p_2x, which returns NaN for
%     all zero parameters.
%
% Reference:
%     [1] Separability criterion and inseparable mixed states with positive
%         partial transposition, Pawel Horodecki,   PLA 232 (1997) p. 333
%

if nargin == 1
    desc = [2 2];
    param_p_func = @param_p_1;
    param_p_size_func = @param_p_1_size;
    param_pure_func = @param_pure_1;
    param_pure_size_func = @param_pure_1_size;
elseif nargin == 2
    param_p_func = @param_p_1;
    param_p_size_func = @param_p_1_size;
    param_pure_func = @param_pure_1;
    param_pure_size_func = @param_pure_1_size;
elseif nargin ~= 6
    help param_sep
    error ('Please follow usage guidelines above');
end

D = prod(desc);
p_pos = param_p_size_func(D^2)+1;
mixing = param_p_func(p(1:(p_pos-1)));

vecs = NaNs(sum(desc),D^2);
for d = 1:D^2
    v_pos = 1;
    for n=1:length(desc)
        p_pos_2 = p_pos + param_pure_size_func(desc(n));
        v_pos_2 = v_pos + desc(n);
        vecs(v_pos:(v_pos_2-1),d) = param_pure_func(p(p_pos:(p_pos_2-1)));
        p_pos = p_pos_2;
        v_pos = v_pos_2;
    end
end

dm = zeros(D,D);
for d = 1:D^2
    pure = 1;
    v_pos = 1;
    for n=1:length(desc)
        v_pos_2 = v_pos + desc(n);
        pure = kron(pure, vecs(v_pos:(v_pos_2-1),d));
        v_pos = v_pos_2;
    end
    dm = dm + mixing(d)*pure2dm(pure);
end

if nargout > 1
    out_vecs = vecs;
    out_mixing = mixing;
end

    
