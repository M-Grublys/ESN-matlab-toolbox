function [t, data] = genSystemEllipse(dt, N, t0, Params)
% genSystemEllipse(dt, N, init, Params)
% Inputs:
%   dt = timestep size
%   N = # iterations (steps) | time range [t0, t0+N*dt]
%   init_time = t0 (initial starting time, determins init [x,y,z])
%  Params = ellipse parameters [a, b]
%           if empty then creates unit circle
%
% 2D system:
%   x(t) = a*cos(t);
%   y(t) = b*sin(t);
%
% Example:
%   Circle:
%   [t, data] = genSystemEllipse(0.01, 1e4, 0, []);
%   Ellipse:
%   [t, data] = genSystemEllipse(0.01, 1e4, 0, [a, b]);

% default system is a circle
if isempty(Params)
    a = 1;
    b = 1;
else
    a = Params(1);
    b = Params(2);
end

f_Fun = @(t) [a*cos(t);
              b*sin(t)];

T = N*dt + t0;    % final end time [t0, T]
t = (t0:dt:T);    % time region
data = f_Fun(t)'; % generate data

end