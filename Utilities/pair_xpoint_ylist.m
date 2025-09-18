function [x, y] = pair_xpoint_ylist(X, Y)
% pair_xpoint_ylist(X, Y)
% Pair data where X is a (1,N) vector and Y is a (N,M) size array.
% Here each row in Y shares the same point X, i.e. the true data is
%   [X(1),Y(1,1); X(1),Y(1,2); ... ; X(1),Y(1,M);
%    X(2),Y(2,1); X(2),Y(2,2); ... ; X(2),Y(2,M);
%                              ...
%    X(N),Y(N,1); X(N),Y(N,2); ... ; X(N),Y(N,M)]
%
% This function sorts data to vectors [x, y] such that (x(i),y(i)) is a
% pair from (X,Y)

N = size(X, 2); % # x-axis points
M = size(Y, 2); % # y-axis points

x = []; % initialise x
y = []; % initialise y

for n=1:N       % for each x
    for m=1:M   % for all m
        x = [x, X(n)];      % add x point (x,.)
        y = [y, Y(n,m)];    % add y point (.,y)
    end
end 