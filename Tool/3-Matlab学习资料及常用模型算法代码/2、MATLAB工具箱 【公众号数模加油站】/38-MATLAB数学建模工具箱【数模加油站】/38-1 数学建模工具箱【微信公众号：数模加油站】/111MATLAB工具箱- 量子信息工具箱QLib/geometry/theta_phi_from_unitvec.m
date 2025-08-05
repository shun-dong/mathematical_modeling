function [theta, phi] = theta_phi_from_unitvec (v)
%
% Extract (theta, phi) from a unit vector
%
% Usage: [theta, phi] = theta_phi_from_unitvec (v)
%     v - A 3-vector
%     [theta, phi] - The result
%

if (v(3) == 0)
    theta = pi/2;
    phi = atan2(v(2),v(1));
else
    theta = atan(((v(1)^2+v(2)^2)^0.5) / v(3));
    if theta < 0
        theta = theta + pi;
    end
    sin_theta = sin(theta);
    phi = atan2(v(2)/sin_theta, v(1)/sin_theta);
end

if phi < 0
    phi = phi + pi*2;
end

