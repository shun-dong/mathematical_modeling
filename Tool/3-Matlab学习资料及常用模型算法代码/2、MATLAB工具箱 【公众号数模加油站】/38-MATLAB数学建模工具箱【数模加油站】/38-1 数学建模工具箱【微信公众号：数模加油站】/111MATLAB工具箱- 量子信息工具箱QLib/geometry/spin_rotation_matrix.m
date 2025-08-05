function U = spin_rotation_matrix (theta,phi)
%
% The matrix rotating FROM a given direction TO the z basis
%
% Usage: U = spin_rotation_matrix (theta,phi)
%

U = [1;0]*spin_at_theta_phi(theta,phi)' + [0;1]*spin_at_theta_phi(theta+pi,phi)';