%% initGridSearch (Launch)
% Setup GridSearch optimisation parameters, supports Random Search
% Launches main script automatically
%
% BENCHMARK PARAMS
%   Define number of samples at each gridpoint
%   Define the number of batches for training (for large train sets)
%   Define evaluation metric (rmse & relative error)
%       Points (by index) = compare performance for fixed-length
%       Thresh (error) = error threshold for threshold time metric
%
% HYPERPARAMETERS
%   Define range for hyperparamters in gridsearch:
%       * reservoirSize (N)
%       * winScalar (eta)
%       * spectral radius (rho)
%       * leaking rate (alpha)
%   Control the number of 'random' gridpoints (random search)
%       numRand = # random values for each hyperparamer (except size)
%       sfDigits = round random values (significant digits)
%
% GRIDSEARCH STRUCT
%   Move data into structs (used in main GridSearch script)
%
% NOTE ON OTHER HYPERPARAMETERS
% all other (non-grid) hyperparameters are initialised inside the main
% GridSearchScript.m file, in "PRE-GRIDSEARCH" section. The default values
% can be found and modified in "DefaultGridsearchHyperparameters()" file

%% BENCHMARK PARAMS
repeatSearch = 100; % # samples (runs) per GSP
numBatches = 10;    % # batches for training (increase for large)

rmsePoints = [57, 112, 222, 443, 885];   % rmse(t_index)
rmseThresh = [0.1, 0.01, 0.001];         % rmse <= thresh
relerrPoints = [57, 112, 222, 443, 885]; % relerrErr(t_index)
relerrThresh = [0.01, 0.001, 0.0001];    % relerrErr <= thresh

%% HYPERPARAMS
% reservoir sizes
reservoirSizeVect = round([500,1000,5000],0);

% hyperparameters (reduce #gridpoints or #samples for speed)
winScalarVect = [0.1, 0.25:0.25:1.25]; % input weights scalar
spectralRadiusVect = [0.05:0.05:2];    % reservoir spectral radius
leakingRateVect = [0.05:0.05:1];       % leaking  rate

numRand = [0, 0, 0];  % # extra (random) params (win, rho, alpha)
sfDigits = [3, 3, 3]; % significant digits (win, rho, alpha)

rng(1982); % rng for random grid
% add random search gridpoints
[winScalarVect, spectralRadiusVect, leakingRateVect] = AddRandomGP(...
    numRand, sfDigits, winScalarVect, spectralRadiusVect, leakingRateVect);

%% GRIDSEARCH STRUCT

% gridpoints
hyperparamGrid = struct(...
    'reservoirSizeVect', reservoirSizeVect,...
    'winScalarVect', winScalarVect,...
    'spectralRadiusVect', spectralRadiusVect,...
    'leakingRateVect', leakingRateVect);

% metrics
benchmarkParams = struct(...
    'rmsePoints', rmsePoints,...
    'rmseThresh', rmseThresh,...
    'relerrPoints', relerrPoints,...
    'relerrThresh', relerrThresh);

% clear
clear numRand sfDigits
clear rmsePoints rmseThresh relerrPoints relerrThresh
clear reservoirSizeVect winScalarVect spectralRadiusVect leakingRateVect


%% RUN GRIDSEARCH

rng(42); % rng seed for gridsearch ESN initialisation

% by default GridSearch script uses parallelisation, which negates fixed
% rng impact. this is only useful if parallelisation (parfor) is removed in
% the main script

tic;
GridSearchScript    % main gridsearch + timer
toc