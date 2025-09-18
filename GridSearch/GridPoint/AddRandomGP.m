function [winScalarVect, spectralRadiusVect, leakingRateVect] = AddRandomGP(...
    numRand, dpDigits, winScalarVect, spectralRadiusVect, leakingRateVect)
% AddRandomGP
% Add random gridsearch points for eta, rho, alpha
% 'Chosen' gridpoints (win/spectral/leaking/...Vect should be
% defined prior. If inputs are empty then output is
% the same as RandomSearch
%
%   input weights eta: uniform [0,2]
%       winScalarVect = [];
%   spectral radius rho: uniform [0,2]
%       spectralRadiusVect = [];
%   leaking rate alpha: uniform [0,1]
%       leakingRateVect = [];
%   # random points (per hyperparam, e.g.)
%       numRand = [5,5,5]
%   d.p. rounding (rand decimal points, e.g.)
%       dpDigits = [2,2,2]
%   

% split # & rounding setting
numEta = numRand(1);   dpEta = dpDigits(1);
numRho = numRand(2); dpRho = dpDigits(2);
numAlpha = numRand(3); dpAlpha = dpDigits(3);

% win scalar [0,2]
winScalarVect = [winScalarVect,...
                 2*round(rand(1, numEta),dpEta)];

% spectral radii [0,2]
spectralRadiusVect = [spectralRadiusVect,...
                      2.5*round(rand(1, numRho), dpRho)];

% leaking rates [0,1]
leakingRateVect = [leakingRateVect,...
                   round(rand(1, numAlpha), dpAlpha)];

% sort in ascending order
winScalarVect = sort(winScalarVect);
spectralRadiusVect = sort(spectralRadiusVect);
leakingRateVect = sort(leakingRateVect);