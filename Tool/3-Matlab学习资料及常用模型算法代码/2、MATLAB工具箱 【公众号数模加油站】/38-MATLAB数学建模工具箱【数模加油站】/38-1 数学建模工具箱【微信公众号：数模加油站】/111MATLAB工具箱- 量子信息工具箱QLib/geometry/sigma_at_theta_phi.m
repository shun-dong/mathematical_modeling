function sigma = sigma_at_theta_phi (theta, phi)
%
% Find the sigma matrix for a given direction in 3D
%
% Usage: sigma = sigma_at_theta_phi (theta, phi)
%     theta    0 for Z, pi/2 for the XY plane, pi for -Z
%     phi      0 for X, pi/2 for Y
%
% Note: Up to a global phase, the eigenvectors of this sigma are given
%       by spin_at_theta_phi(...)
%

global QLib;

sigma = sin(theta)*(cos(phi) * QLib.sigma.x + sin(phi)*QLib.sigma.y) + cos(theta)*QLib.sigma.z;

