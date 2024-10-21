function [t, data] = genSystemRossler(dt, N, init, Params)
% genSystemRossler(dt, N, init, Params)
% Inputs:
%   dt = timestep size
%   N = # iterations (steps)
%   init = [x0,y0,z0] (initial condition)
%   Params = Rossler system parameters vector:
%       [a, b, c]
%
% Rossler System:
%   dx = -y-z;
%   dy = x + a*y;
%   dz = b + z(x-c);
%
% Example:
%   [t, data] = genSystemRossler(0.01, 1e4,...
%               [-9,0,0], [0.2,0.2,5.7]);
%           % MLE ~ [0.0714, 0, -5.3943]
%
% Simulation is done using ODE45 MATLAB solver

a = Params(1);
b = Params(2);
c = Params(3);

f_Rossler = @(t, X) [-X(2) - X(3);...
                    X(1) + a*X(2);...
                    b + X(3)*(X(1) - c)];

data = init; t=0;
wbar = waitbar(0,'Simulating Rossler System');

for i = 1:N
    [t_temp, init] = ode45(f_Rossler, [0, dt], init(end,:));
    data = [data; init(end,:)];
    t = [t; t(end)+t_temp(end)];
    waitbar(i/N, wbar);
end
close(wbar);

data = data';
t = t';
end