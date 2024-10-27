function [GMRA, trainTimeGRA,...
          rmsePointGRC, rmseThreshGRC,...
          relerrPointGRC, relerrThreshGRC] ...
          = CreatePerformanceTable(hyperparamGrid, benchmarkParams,...
                                   trainTimeGPM, trainTimeHC,...
                                   rmsePointGPM, rmsePointGHC,...
                                   rmseThreshGPM, rmseThreshGHC,...
                                   relerrPointGPM, relerrPointGHC,...
                                   relerrThreshGPM, relerrThreshGHC)
% CreatePerformanceTable
% Store the gridsearch results as an array (GMRA):
%   *) Array - each column is a parameter:
%       # reservoirSize | winScalar | spectralRadius | leakingRate
%       # fixed-time-test value | error at fixed-time-test value
%   *) Works with MEAN values
%
% 1) Sort GPM target pairs (benchmarkParam, meanValue)
% 2) Sort data to the mean results array(GMRA)
% 3) Split data to arrays & cells by category
%
% ACRONYMS: check GridsearchScript.m allocation part

% counters
    I1 = length(hyperparamGrid.reservoirSizeVect);  % # reservoir sizes
    I2 = length(hyperparamGrid.winScalarVect);      % # winScalars
    I3 = length(hyperparamGrid.spectralRadiusVect); % # spectral radii
    I4 = length(hyperparamGrid.leakingRateVect);    % # leaking rates

% benchmarkParams
    rmsePoints = benchmarkParams.rmsePoints;     % rmse points
    rmseThresh = benchmarkParams.rmseThresh;     % rmse thresh
    relerrPoints = benchmarkParams.relerrPoints; % relative rmse points
    relerrThresh = benchmarkParams.relerrThresh; % relative rmse thresh

% # points of interest    
    numRMSEPoints = size(rmsePoints,2);     % # rmse points
    numRMSEThresh = size(rmseThresh,2);     % # rmse thresh
    numRelerrPoints = size(relerrPoints,2); % # relative rmse Points
    numRelerrThresh = size(relerrThresh,2); % # relative rmse Thresh

% STORAGE
    GMRA = [];  % all (mean) results as array

    % gridsearch results cells (GRC)
    rmsePointGRC = cell(1,numRMSEPoints);      % rmse points 
    rmseThreshGRC = cell(1,numRMSEThresh);     % rmse thresh
    relerrPointGRC = cell(1,numRelerrPoints);  % relative rmse points
    relerrThreshGRC = cell(1,numRelerrThresh); % relative rmse thresh

    trainTimeGRA = [];  % GP train time results array

% FOR each reservoirSize
for i1=1:I1
%-% FOR each winScalar
    for i2=1:I2
%-----% FOR each spectralRadius
        for i3=1:I3
%---------% FOR each leakingRate
            for i4=1:I4               
%---------% 1) SORT GPM target pairs (benchmarkParam, meanValue)
                % point & mean rmse pair
                pairsRMSEPoint = [];
                for j=1:numRMSEPoints
                    pairsRMSEPoint = [pairsRMSEPoint,...
                                    rmsePoints(j), rmsePointGPM(i1,i2,i3,i4,j)];
                end
                % rmse thresh & mean time (length) pair
                pairsRMSEThresh = [];
                for j=1:numRMSEThresh
                    pairsRMSEThresh = [pairsRMSEThresh,...
                        rmseThresh(j), rmseThreshGPM(i1,i2,i3,i4,j)];
                end
                % point & mean relerr pair
                pairsRelerrPoint = [];
                for j=1:numRelerrPoints
                    pairsRelerrPoint = [pairsRelerrPoint,...
                        relerrPoints(j), relerrPointGPM(i1,i2,i3,i4,j)];
                end
                % relerr thresh & mean time (length) pair
                pairsRelerrThresh = [];
                for j=1:numRelerrThresh
                    pairsRelerrThresh = [pairsRelerrThresh,...
                        relerrThresh(j), relerrThreshGPM(i1,i2,i3,i4,j)];
                end
                
%---------% 2) SORT DATA TO THE MEAN RESULTS ARRAY (GMRA)
                % GMRA; column notation |.|  as follows:
                % reservoirSize | winScalar | spectralRadius | leakingRate
                % mean training time                         |
                % pairs: rmsePoint(j),      mean(rmse(j))    |
                % pairs: rmseThresh(j),     mean(time(j))    |
                % pairs: relerrPoint(j),   mean(relerr(j))  |
                % pairs: relerrThresh(j),  mean(time(j))     |
                GMRA = [GMRA;
                    hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                    hyperparamGrid.winScalarVect(i2),...      % winScalar
                    hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                    hyperparamGrid.leakingRateVect(i4),...    % leakingRate
                    trainTimeGPM(i1,i2,i3,i4),...         % mean training time
                    pairsRMSEPoint,...                    % pairs: rmsePoints & mean rmse
                    pairsRMSEThresh,...                   % pairs: rmseThresh & mean time
                    pairsRelerrPoint,...                  % pairs: relerrPoints & mean relerr
                    pairsRelerrThresh];                   % pairs: relerrThresh & mean time

%---------% 3) SPLIT DATA TO ARRAYS & CELLS BY CATEGORY
                % trainTime gridsearch results array (# repeats as cols)
                trainTimeGRA = [trainTimeGRA;
                     hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                     hyperparamGrid.winScalarVect(i2),...      % winScalar
                     hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                     hyperparamGrid.leakingRateVect(i4),...    % leakingRate
                     trainTimeHC{i1}{i2}{i3}{i4}(:)']; % train times (# repeats as col vect)
                 
                % rmsePoints & all rmse values (# repeats as cols)
                for j=1:numRMSEPoints
                rmsePointGRC{j} = [rmsePointGRC{j};
                    hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                    hyperparamGrid.winScalarVect(i2),...      % winScalar
                    hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                    hyperparamGrid.leakingRateVect(i4),...    % leakingRate
                    rmsePoints(j),...                     % rmsePoint(j)
                    rmsePointGHC{i1}{i2}{i3}{i4}(:,j)'];  % rmse (# repeats as col vect)
                end
                
                % rmseThresh & all times (# repeats as cols)
                for j=1:numRMSEThresh
                rmseThreshGRC{j} = [rmseThreshGRC{j};
                    hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                    hyperparamGrid.winScalarVect(i2),...      % winScalar
                    hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                    hyperparamGrid.leakingRateVect(i4),...    % leakingRate
                    rmseThresh(j),...                     % rmseThresh(j)
                    rmseThreshGHC{i1}{i2}{i3}{i4}(:,j)']; % times (# repeats as col vect)
                end  
                
                % relerrPoints & all relative error values (# repeats as cols)
                for j=1:numRelerrPoints
                    relerrPointGRC{j} = [relerrPointGRC{j};
                    hyperparamGrid.reservoirSizeVect(i1),...    % reservoirSize
                    hyperparamGrid.winScalarVect(i2),...        % winScalar
                    hyperparamGrid.spectralRadiusVect(i3),...   % spectralRadius
                    hyperparamGrid.leakingRateVect(i4),...      % leakingRate
                    relerrPoints(j),...                    % relerrPoint(j)
                    relerrPointGHC{i1}{i2}{i3}{i4}(:,j)']; % relative rmse (# repeats as as col vect)
                end
                
                % relerrThresh & all times (# repeats as cols)
                for j=1:numRelerrThresh
                    relerrThreshGRC{j} = [relerrThreshGRC{j};
                    hyperparamGrid.reservoirSizeVect(i1),...     % reservoirSize
                    hyperparamGrid.winScalarVect(i2),...         % winScalar
                    hyperparamGrid.spectralRadiusVect(i3),...    % spectralRadius
                    hyperparamGrid.leakingRateVect(i4),...       % leakingRate
                    relerrThresh(j),...                     % relerrThresh(j)
                    relerrThreshGHC{i1}{i2}{i3}{i4}(:,j)']; % times (# repeats as col vect)
                end
                
            end
        end
    end
end
