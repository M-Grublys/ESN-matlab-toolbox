function [t, data] = genSystemLiu(dt, N, init, Params)
% genSystemLiu(dt, N, init, Params)
% Inputs:
%   dt = timestep size
%   N = # iterations (steps)
%   init = [x0,y0,z0] (initial condition)
%   Params = Liu system parameters vector:
%       [a, b, k, c, h]
%
% Liu System:
%   dx = a*(y-x);
%   dy = b*x - k*x*z;
%   dz = -c*z + h*x*x;
%
% Example:
%   [t, data] = genSystemLiu(0.01, 1e4,...
%               [2.2,2.4,38], [10,40,1,2.5,4]);
%           % MLE ~ [1.64328, 0, -14.142]
%
% Simulation is done using ODE45 MATLAB solver
%
% System ref: doi:10.1016/j.chaos.2004.02.060

a = Params(1);
b = Params(2);
k = Params(3);
c = Params(4);
h = Params(5);

f_Liu = @(t, X) [a*(X(2) - X(1));...
                 b*X(1) - k*X(1)*X(3);...
                 -c*X(3) + h*X(1)*X(1)];

data = init; t=0;
wbar = waitbar(0,'Simulating Liu System');

for i = 1:N
    [t_temp, init] = ode45(f_Liu, [0, dt], init(end,:));
    data = [data; init(end,:)];
    t = [t; t(end)+t_temp(end)];
    waitbar(i/N, wbar);
end
close(wbar);

data = data';
t = t';

end