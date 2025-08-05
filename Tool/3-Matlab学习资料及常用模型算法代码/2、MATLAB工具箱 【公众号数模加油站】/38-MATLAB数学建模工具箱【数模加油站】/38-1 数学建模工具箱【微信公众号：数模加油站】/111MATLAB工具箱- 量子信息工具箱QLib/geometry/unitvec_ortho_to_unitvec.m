function w = unitvec_ortho_to_unitvec(v, phi)
%
% Create a unit vector ortogonal to a given unit vector
%
% Usage: w = unitvec_ortho_to_unitvec(v<, phi>)
%     v: The unit vector (3-vector)
%     phi: The angle of the requested vector (default: 0)
%     w: A vector orthogonal to v and to the direction phi
%

if nargin == 1
    phi = 0;
end

if (v(1) == 0) & (v(2) == 0) & (v(3) == 1)
    w = unitvec_from_theta_phi (pi/2, phi);
else
    t1 = cross(v, [1 0 0]');  t1 = t1 ./ (t1' * t1)^0.5;
    t2 = cross(v, t1);        t2 = t2 ./ (t2' * t2)^0.5;
    w = t1*cos(phi) + t2*sin(phi);
end