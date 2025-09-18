function [origU] = window2series(windowU, tsDim, T, windowLength)
% window2series
% reshape window time-series windowU of shape (D*L, T-L) into 'original'
% time-series U of shape (D, T). Here L is the windowLength and D is the
% dimension of original time-series.
% NOTE: for length "L" input windowLength = L+1
%       e.g. L=0 -> "no window", L=3 -> [u(1),...,u(4)]'
%
%   inputs:
%       windowU = window time-series of shape (D*L,T-L)
%       tsDim   = dimension of original time-series
%       T       = length of original time-series
%       windowLength = size of the window, e.g. L=2 -> [u(1), u(2), u(3)]'
%
% [origU] = window2series(windowU, tsDim, T, windowLength)

origU = zeros(tsDim,T);
L = windowLength;

% deal with the  first L-1 entires that are only in the 1st column
for i = 1:L+1
    origU(:,i) = windowU(1+tsDim*(i-1):tsDim*i,1);
end
% get the rest of the time-series from "last" D entries
origU(:,(L+1):end) = windowU(end-(tsDim-1):end,1:end);