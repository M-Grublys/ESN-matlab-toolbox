function [trainTime, rmsePointVals, rmseThreshVals, relerrPointVals, relerrThreshVals] = ...
    TestGridPoint(benchmarkParams,...
                        hyperparameters, ioDims,...
                        trainU, trainY, testU, testY, numBatches,...
                        washout, testLength)
% TestGridPoint
% Test the current grid-point (winScalar, spectralRadius, leakingRate)
% 1) generate and train an ESN (at gridpoint)
% 2) generate forecast & test performance
%   *) rmse & relative error at fixed points & threshold time
% 3) outputs: performance metrics & training time

tic;
% create & train an ESN
esn = ESN('hyperparameters',hyperparameters,'ioDims',ioDims);
%esn.Train(trainU, trainY, washout); % train
esn.TrainBatch(trainU, trainY, washout, numBatches); % train
trainTime = toc;                    % training time

% benchmark forecasting
Y = esn.Forecast(testU(:,1),testLength);

% evaluate performance
[rmsePointVals, rmseThreshVals, relerrPointVals, relerrThreshVals] = GPPerformance(...
    benchmarkParams, testY(:,1:testLength), Y(:,1:testLength));

% Update vectors (old)
% rmsePointVect = [rmsePointVect; rmsePointVals];          % rmse at (t)
% rmseThreshVect = [rmseThreshVect; rmseThreshVals];       % rmse thresh time
% relerrPointVect = [relerrPointVect; relerrPointVals];    % relative rmse at (t)
% relerrThreshVect = [relerrThreshVect; relerrThreshVals]; % relative rmse thresh time
