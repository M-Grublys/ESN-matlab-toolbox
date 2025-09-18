function [t, data] = genSystemSinCosSum(dt, N, t0, a, b)
% genSystemSinCosSum(dt, N, t0, a, b)
% Inputs:
%   dt = timestep size
%   N = # iterations (steps) | time range [t0, t0+N*dt]
%   init_time = t0 (initial starting time)
%   a,b = constant parameters of the system
%
% 1D system:
%   f(t) = sin(a*t) + cos(b*t);
%
% Example:
%   [t, data] = getSystemSinCosSum(0.01, 1e4, 1, sqrt(2));

f_Fun = @(t) cos(a*t) + sin(b*t);

T = N*dt + t0;   % final end time [t0, T]
t = (t0:dt:T);   % time region
data = f_Fun(t); % generate data

end