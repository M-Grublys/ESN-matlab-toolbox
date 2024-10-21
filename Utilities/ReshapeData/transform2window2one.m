function [newX, newY] = transform2window2one(U, windowLength)
% transform2window2one(U, windowLength)
% reshape time-series U of shape (D,T) into a new "window" time-series in
% shape (D*L, T-L) where L is windowLength.
% This is named newX
% Then introduce a second "newY" such that
%   we have pairs such that (dim=1, windowLength=2)
%       newX(1) = [u(1), u(2), u(3)]
%       newY(1) = [u(4)]
%
% look at "help transform2window" for more detail
% NOTE: here the TS will be a bit shorter (-1) due to newX->newY mapping
% that is, newX(1) has no corresponding 'match' in newY(.)
%
% output:
%   [newX, newY] = transform2window2one(U, windowLength)
%
L = windowLength;   % windowLength (short name)
[D, T] = size(U);   % dim-size, ts-length

newX = zeros(D*(L+1), T-L-1);
newY = zeros(D, T-L-2);

for t = 1:T-L%-1     % Go through TS, note T-L-1 (not T-L) due to newY var
    % get window vector
    windowVect = zeros(D*(L+1), 1);
    for  i=1:D  % add U(i,:) to window
        windowVect(i:D:end) =  U(i,t:t+L);  % [u(t),...,u(t+L)]' window
    end
    % add to window timeseries (column)
    newX(:,t) = windowVect';
    % newY(:,t) = U(:,t+L+1);
end

newY = newX(end-(D-1):end,2:end);   % mapping [u(t-i)...u(t)] -> [u(t+1)]
newX(:,end) = [];                   % remove last entry (no mapping target)