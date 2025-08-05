function [theta,phi] = theta_phi_from_spin (v)
%
% Compute the direction of a given spinor
%
% Usage: [theta,phi] = theta_phi_from_spin (v)
%     v - A spinor (a 2-vector)
%     theta,phi - It's direction
%


vv = no_global_phase(v);

if is_close(vv(2),0)
    theta=0;
    phi = 0;
elseif is_close(vv(1),0)
    theta=pi;
    phi  =0;
else
    z = abs(vv(2));
    theta = 2*atan2(z, vv(1));
    phi   = atan2(imag(vv(2))/z,real(vv(2))/z);

    phi   = cleanup(phi);
    theta = cleanup(theta);
end