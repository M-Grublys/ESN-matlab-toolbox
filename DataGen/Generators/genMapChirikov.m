function [t, data] = genMapChirikov(N, init, Params)
% genMapChirikov(N, init, Params)
% Inputs:
%   N = # iterations (steps)
%   init = [x0,y0] (initial condition)
%   Params = Chirikov map parameters vector:
%       [K]
%
% Chirikov Map:
%   Y(n+1) = mod( Y(n) + K*sin( X(n) ) , 2*pi);
%   X(n+1) = mod( X(n) + Y(n+1) , 2*pi);
%
% Example:
%   [t, data] = genMapChirikov(1e4, [0,6], [1]);
%           % MLE ~ +- 0.10497
%

K = Params(1);

wbar = waitbar(0,'Simulating Chirikov Standard Map');

data = zeros(2,N);
data(1,1)=init(1); data(2,1)=init(2);   % allocate arrays & i.c.
for t=2:N % iterate
    data(2,t) = mod( data(2,t-1) + K*sin( data(1,t-1) ), 2*pi);
    data(1,t) = mod( data(1,t-1) + data(2,t), 2*pi);
    waitbar(t/N, wbar);
end
close(wbar);

t = 1:1:N;

end