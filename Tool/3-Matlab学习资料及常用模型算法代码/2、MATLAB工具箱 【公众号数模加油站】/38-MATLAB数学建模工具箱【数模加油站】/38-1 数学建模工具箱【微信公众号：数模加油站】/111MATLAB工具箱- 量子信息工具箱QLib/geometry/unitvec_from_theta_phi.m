function v=unitvec_from_theta_phi (theta, phi)
%
% Compute the unit vector for a given angle
%
% Usage: v=unitvec_from_theta_phi (theta, phi)
%     theta, phi - The angle
%     v - The resultant 3-vector
%

v = zeros(3,1);
v(1) = sin(theta)*cos(phi);
v(2) = sin(theta)*sin(phi);
v(3) = cos(theta);
end