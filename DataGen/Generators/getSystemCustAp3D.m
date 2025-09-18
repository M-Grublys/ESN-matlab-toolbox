function [t, data] = getSystemCustAp3D(dt, N, t0)
% getSystemCustAp3D(dt, N, init)
% Inputs:
%   dt = timestep size
%   N = # iterations (steps) | time range [t0, t0+N*dt]
%   init_time = t0 (initial starting time, determines init [x,y,z])
%
% 3D system (arbitrary):
%   x(t) = tanh(t).*cos(t);
%   y(t) = tanh(t).*sin(t);
%   z(t) = tanh(t).*exp(cos(t)+sin(sqrt(t))));
%
% Example:
%   [t, data] = getSystemCustAp3D(0.01, 1e4, 0);


f_Fun = @(t) [tanh(t).*cos(t);...
              tanh(t).*sin(t);...
              tanh(t).*exp(cos(t)+sin(sqrt(t)))];

T = N*dt + t0;    % final end time [T after N steps]
t = (t0:dt:T);    % time region [t0, T] vector
data = f_Fun(t)'; % generate data
t = t';           % transpose time to row-vector

end