function v = spin_at_theta_phi (theta, phi)
%
% Spinor at requested direction
%
% Usage: v = spin_at_theta_phi (theta, phi)
%     theta, phi - The direction
%     v          - The spinor (a.k.a. a pure state)
%
% To get a dm of this spinor: rho = pure2dm(spin_at_theta_phi (theta,phi));
%

v(1,1) = cos(theta/2);
v(2,1) = sin(theta/2) * exp (i*phi);
