function [RRS] = get_EvalRelRatioSpacings(evals)
% get eigenvalue relative ratio spacings:
%
%   input:  vector of eigenvalues
%   output: eigenvalue relative ratio spacings
%
% Equation: RRS(i) = (L(i+1)-L(i)) / (L(i)-L(i))
%
% Note: L = eigenvalue,
%       "i+1=(3:end)", "i=(2:end-1)", "i-1=(1:end-2)"

RRS = ( evals(3:end) - evals(2:end-1) ) ./...
      ( evals(2:end-1) - evals(1:end-2) );