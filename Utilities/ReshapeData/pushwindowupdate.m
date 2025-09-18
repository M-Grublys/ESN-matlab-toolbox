function [newX] = pushwindowupdate(X, Y, dim)
% pushwindowupdate(X, Y, dim)
% push (remove) the 'last' X(t)-step and add the 'new' found Y values
%   input:
%       X = 'input' data window where push will happen
%       Y = 'output' data of same size, where last entry of Y is 'pushed'
%       into X
%       dim = original dimension of X,Y
%
%   output:
%       newX = new 'pushed' X
%
%   example (dim=1, window=3)
%       X = [u(1), u(2), u(3)]
%       Y = [u(2), u(3), u(4)]
%       newX = [u(2), u(3), u(4)]
%
% [newX] = pushwindowupdate(X, Y, dim)

newX = [X(1+dim:end,:); Y(end-(dim-1):end,:)];
