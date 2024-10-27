function [rmsePointVals, rmseThreshVals, relerrPointVals, relerrThreshVals] = ...
    GPPerformance( benchmarkParams, testY, Y )
% GPPerformance
% Evaluate ESNs performance for benchmarkParams at current gridpoint
% Outputs: rmse and relative error, at fixed points & threshold times
    
rmsePoints = benchmarkParams.rmsePoints;     % rmse points vector
rmseThresh = benchmarkParams.rmseThresh;     % threshold vector
relerrPoints = benchmarkParams.relerrPoints; % relative rmse points vector
relerrThresh = benchmarkParams.relerrThresh; % relative rmse threshold vector

numRMSEThresh = size(benchmarkParams.rmseThresh,2);      % # rmse thresh
numRelerrThresh = size(benchmarkParams.relerrThresh,2); % # relative rmse thresh

% evaluate trained esn
[rmseSeries, ~, relerrSeries] = ESNPerformanceSeries(testY, Y);

% record values of interest
rmsePointVals = rmseSeries(rmsePoints);          % rmse vals 
relerrPointVals = relerrSeries(relerrPoints); % relerr vals

% THRESHOLD: rmse time             
rmseThreshVals = zeros(1,numRMSEThresh);
for j=1:numRMSEThresh       % FOR each rmse threshold
    % find the break point (time) for given threshold
    tempVar = find(rmseSeries < rmseThresh(j), 1, 'last');
    if isempty(tempVar)     % if poor performance (breaks at t=0)
        rmseThreshVals(1,j) = 0;  
    else                    % else set thresh break time
        rmseThreshVals(1,j) = tempVar;
    end
end

% PERCENT THRESHOLD: relerr time
relerrThreshVals = zeros(1, numRelerrThresh);
for j=1:numRelerrThresh    % FOR each relerr threshold
    % find the break point (time) for given threshold
    tempVar = find(relerrSeries < relerrThresh(j), 1, 'last');
    if isempty(tempVar)         % if poor performance (breaks at t=0)
        relerrThreshVals(1,j) = 0;
    else                        % else set relerr thresh break time
        relerrThreshVals(1,j) = tempVar;
    end
end