function [t, data] = genMapHenon(N, init, Params)
% genMapHenon(N, init, Params)
% Inputs:
%   N = # iterations (steps)
%   init = [x0,y0] (initial condition)
%   Params = Henon map parameters vector:
%       [a, b]
%
% Henon Map:
%   X(n+1) = 1 - a*X(n)^2 + b*Y(n)
%   Y(n+1) = X(n);
%
% Example:
%   [t, data] = genMapHenon(1e4, [0,0.9], [1.4, 0.3]);
%           % MLE ~ [+0.41922, -1.62319]
% Simulation is done using ODE45 MATLAB solver
%

a = Params(1);
b = Params(2);

data = zeros(2,N+1);
data(:,1) = init;
wbar = waitbar(0,'Simulating Henon Map');

for t = 1:N
    data(1,t+1) = 1 - a*data(1,t)^2 + b*data(2,t);
    data(2,t+1) = data(1,t);
    waitbar(t/N, wbar);
end
close(wbar);

t = 0:1:N;

end