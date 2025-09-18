function [evals, evects] = ComputeEchoesEigenstats(X, doEigReg, evalRegParam)
% ComputeEchoesEigenstats
%   X = matrix (of echoes)
%   doEigReg = true/false (use ridge regression?)
%   evalRegParam = ridge parameter
%
% MATLAB sorts eigenvalues in ascending
% order by default in eig(), with corresponding
% eigenvectors pair found by column index.
%   eigenvalue evals(i)
%   eigenvector evects(:,i)

evalMatSize = size(X,1); % time-series dim

if doEigReg
    evalMatX = X * X' + evalRegParam*eye(evalMatSize);
else
    evalMatX = X * X';
end

[evects, evals] = eig(evalMatX);
evals = diag(evals);