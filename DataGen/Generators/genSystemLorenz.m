function [t, data] = genSystemLorenz(dt, N, init, Params)
% genSystemLorenz(dt, N, init, Params)
% Inputs:
%   dt = timestep size
%   N = # iterations (steps)
%   init = [x0,y0,z0] (initial condition)
%   Params = Lorenz system parameters vector:
%       [sigma, beta, rho]
%
% Lorenz System:
%   dx = sigma*(y-x);
%   dy = x*(rho-z) - y;
%   dz = x*y - beta*z;
%
% Example:
%   [t, data] = genSystemLorenz(0.01, 1e4,...
%               [1,1,1], [10, 8/3, 28]);
%           % MLE ~ [0.9056, 0, -14.5723]
% Simulation is done using ODE45 MATLAB solver
% Note: MLE for Lorenz system is between 0.9 and 1.0 for most ic
%       Our primary source material for DS uses ic [0, -0.01, 9]
%

sigma = Params(1);
beta = Params(2);
rho = Params(3);

f_Lorenz = @(t, X) [sigma*(X(2) - X(1));
                    X(1)*(rho-X(3)) - X(2);
                    X(1)*X(2) - beta*X(3)];

data = init; t=0;
wbar = waitbar(0,'Simulating Lorenz System');

for i = 1:N
    [t_temp, init] = ode45(f_Lorenz, [0, dt], init(end,:));
    data = [data; init(end,:)];
    t = [t, t(end)+t_temp(end)];
    waitbar(i/N, wbar);
end
close(wbar);

data = data';
%t=t';
end