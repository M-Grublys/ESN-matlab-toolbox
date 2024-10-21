function [esn, ESNPerformanceResults] = ...
              GenerateMeanThreshESN(hyperparameters, washout,...
                                 trainU, trainY, testU, testY,...,
                                 numBatches, GenESNThreshParams)
% [esn, ESNPerformanceResults] = GenerateMeanPThreshESN(...
%         hyperparameters, washout, trainU, trainY, ...
%         testU, testY, numBatches, GenESNThreshParams);
%
%   Generate up to "GenESNThreshParams.numAttempts" ESNs, then pick either
%   the first that exceeds desired target performance, or the best ESN
%   (after numAttempts)
%
%   Main settings are defined in struct "GenESNThreshParams", e.g.
%
%   GenESNThreshParams = struct(...
%       'threshValue', 0.001,...            % error threshold value
%       'threshType', 'relerr',...          % threshold type: rmse/relerr
%       'targetPerformance', testLength,... % target performance (length)
%       'numAttempts',3,...                 % # attempts
%       'keepTrainingState',true,...        % keep pre-forecast esn state
%       'printTrainingOutcome',true);       % print training outcome
%
%   Currently only supports optimisation based on maximum threshold time

inDim = size(trainU,1);     % training data dims
outDim = size(trainY,1);    %
ioDims = [inDim, outDim];   % input/output

testLength = size(testU,2);

% get GenESNThreshParams
threshValue = GenESNThreshParams.threshValue;             % mean threshold (err<thresh)
threshType = GenESNThreshParams.threshType;               % error type: 'rmse/relerr'
targetPerformance = GenESNThreshParams.targetPerformance; % desired performance (time/length)

if targetPerformance > testLength
    fprintf('Need more test data:\n\ttargetPerformance (%d)\n\ttestLength (%d)\n\n',...
            targetPerformance, testLength);
end

numAttempts = GenESNThreshParams.numAttempts;  % # attemtps to generate a good ESN

currentBestPerformance = 0; % assume unknown (0) performance
performanceVect = [];       % record/append all results
currentPerformance = -1;    % initialise performance var ('length=-1')

%% GENERATION PROCESS
m = 0;
while m < numAttempts
    m=m+1;
    % initialise ESN
    testESN = ESN('hyperparameters',hyperparameters,'ioDims',ioDims,solverType='default'); % 'projections'
    % train ESN
    %testESN.Train(trainU, trainY, washout); % old - only 1 batch
    testESN.TrainBatch(trainU, trainY, washout, numBatches); % # batches for large training sets

    % remember pre-forecast (performance test) state
    x = testESN.x;
    % forecast - evaluate ESNs performance w.r.t. err threshold
    Y = testESN.Forecast(testU(:,1), testLength);
    [rmseSeries, ~, relerrSeries] = ...
        ESNPerformanceSeries(testY(:,1:testLength), Y(:,1:testLength));

    switch lower(threshType)
        case 'relerr'   % RELERR
            % find relerr threshold index
            tempVar = find(relerrSeries < threshValue, 1, 'last');
            if isempty(tempVar)
                currentPerformance = 0;       % does not exist 
            else
                currentPerformance = tempVar; % threshold index
            end
        otherwise       % RMSE
            % find relerr threshold index
            tempVar = find(rmseSeries < threshValue, 1, 'last');
            if isempty(tempVar)
                currentPerformance = 0;       % does not exist 
            else
                currentPerformance = tempVar; % threshold index
            end
    end

    % keep the best performing esn
    if currentPerformance >= currentBestPerformance  % if new is better
        esn = testESN;                               % new best ESN
        currentBestPerformance = currentPerformance; % new best Performance
        if GenESNThreshParams.keepTrainingState      % optional (true by default):
            esn.x = x;                               % reset ESNs state
        end
    end
    % update/append performance vector
    performanceVect = [performanceVect, currentPerformance]; 
   
    % stop if current ESN reached desired performance (error threshold)
    if currentBestPerformance>=targetPerformance
        break;
    end
end

% optional: print generation results
if GenESNThreshParams.printTrainingOutcome
    % failed to reach target, print best ESN
    if currentBestPerformance<targetPerformance
        fprintf('Failed to generate an ESN with desired performance\n')
        fprintf('Best ESN performance:  %f\n', currentBestPerformance)
    else
        % print the performance of best (output) ESN
        fprintf('Best ESN performance:  %f\n', currentBestPerformance)
    end
end

% record the generation process results
ESNPerformanceResults = struct(...
    'performance', currentBestPerformance,...   % output ESN performance
    'attempts', m,...                           % # attemps taken (ESNs generated)
    'targetPerformance', GenESNThreshParams.targetPerformance,... % target performance (from input)
    'performanceVect',performanceVect,...       % performance of all "m" ESNs
    'meanPerformance',mean(performanceVect),... % mean performance of all "m" ESNs
    'filteredMean',mean(performanceVect(~isoutlier(performanceVect)))); % ^ mean without outliers
    % if m=1 (first is best) then mean values are pointless              