function H = param_H_2_rand(desc)
%
% Generate a random H (using H parametrization 2)
%
% Usage: H = param_H_2_rand(desc)
%

H = param_H_2(1000*randrow(param_H_2_size(desc)));
