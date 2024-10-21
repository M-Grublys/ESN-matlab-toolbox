function [newU] = transform2window(U, windowLength)
% transform2window(U, windowLength)
% reshape time-series U of shape (D,T) into a new "window" time-series in
% shape (D*L, T-L) where L is windowLength
%
%   inputs:
%       U            = time-series of shape (D,T)
%       windowLength = length of new "window"
%                      NOTE: for length "L" input windowLength = L+1
%                      e.g. L=0 -> "no window", L=3 -> [u(1),...,u(4)]
%
%   FROM: (d,T)
%       U = [[u(1,1)], [u(1,2)], [...], [u(1,T)]]
%             ...       ...       ...    ...
%           [[u(d,1)], [u(d,2)], [...], [u(d,T)]]
%
%   TO: (d*L,T-L) where L=windowLength
%    newU = [[u(1,1)], [u(1,2)]],   [...], [u(1,T-L)]]
%             ...       ...          ...    ...
%            [u(d,1)], [u(d,2)],    [...], [u(d,T-L)]
%            [u(1,2)], [u(1,3)],    [...], [u(1,T-(L-1)]
%             ...       ...          ...    ...
%           [[u(d,L)], [u(d,L+1)],  [...], [u(d,T)]]
%
% [newU] = transform2window(U, windowLength)

[D, T] = size(U); % get dimension & length of time-series

newU = zeros(D*(windowLength+1), T-windowLength);   % window-shape

for t = 1:T-windowLength    % go through the time-series
    % get window vector
    windowVect = zeros(D*(windowLength+1), 1);
    for  i=1:D    % add U(i,:) to window
        windowVect(i:D:end) =  U(i,t:t+windowLength);  % [u(t),...,u(t+L)]' window
    end
    % add to window timeseries (column)
    newU(:,t) = windowVect';
end

end