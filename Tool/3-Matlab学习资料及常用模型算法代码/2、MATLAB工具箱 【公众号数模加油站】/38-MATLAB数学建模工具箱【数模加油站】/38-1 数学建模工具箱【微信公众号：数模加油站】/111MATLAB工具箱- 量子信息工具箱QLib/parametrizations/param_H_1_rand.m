function H = param_H_1_rand(desc)
%
% Generate a random H (using H parametrization 1)
%
% Usage: H = param_H_1_rand(desc)
%

H = param_H_1(1000*randrow(param_H_1_size(desc)));
