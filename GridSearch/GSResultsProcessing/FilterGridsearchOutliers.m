function [OptimalGSParamsFiltered, GMRAFiltered,...
          rmsePointFGHC, rmseThreshFGHC,...
          relerrPointFGHC, relerrThreshFGHC] ...
          = FilterGridsearchOutliers(hyperparamGrid, benchmarkParams,...
                                   rmsePointGHC, rmseThreshGHC,...
                                   relerrPointGHC, relerrThreshGHC) 
%FilterGridsearchOutliers
% Gridsearch results without outliers (filtered/removed)
% DOES NOT INCLUDE TRAINING TIME
% Store the gridsearch results as array:
%   *) Array - each column is a parameter:
%       # reservoirSize | winScalar | spectralRadius | leakingRate
%       # fixed-time-test value | error at fixed-time-test value
%   *) Works with MEAN values
%
% Sort Data
%   1) Remove outliers & sort GPM target pairs (benchmarkParam, mean)
%   2) Record main arrays data - without outliers
% Find filtered optimal params (without outliers)
%   1) Find optimal result at each gridpoint (GP)
%
% F-prefix = Filtered
%   GMRAFiltered = Filtered GMRA (gridsearch mean results array)
%   FGHC = filtered gridsearch history cell
% for more ACRONYMS check GridsearchScript.m allocation

% counters
    I1 = length(hyperparamGrid.reservoirSizeVect);  % # reservoir sizes
    I2 = length(hyperparamGrid.winScalarVect);      % # winScalars
    I3 = length(hyperparamGrid.spectralRadiusVect); % # spectral radii
    I4 = length(hyperparamGrid.leakingRateVect);    % # leaking rates

% benchmarkParams
    rmsePoints = benchmarkParams.rmsePoints;       % rmse points
    rmseThresh = benchmarkParams.rmseThresh;       % rmse thresh
    relerrPoints = benchmarkParams.relerrPoints;  % relerr points
    relerrThresh = benchmarkParams.relerrThresh;  % relerr thresh

% # points of interest    
    numRMSEPoints = size(rmsePoints,2);       % # rmse points
    numRMSEThresh = size(rmseThresh,2);       % # rmse thresh
    numRelerrPoints = size(relerrPoints,2); % # relerrPoints
    numRelerrThresh = size(relerrThresh,2); % # relerrThresh

% STORAGE
    GMRAFiltered = []; % all filtered (mean) results as array

    % filtered history cells (FGHC), and means/outliers at each gp
   
    % rmsePoint filtered: history cell, means & outliers arrays
    rmsePointFGHC = SetupGSDataCell(hyperparamGrid);           % history cell
    filteredRMSEPointGPM = -ones(I1,I2,I3,I4, numRMSEPoints);  % gp filtered means
    rmsePointOutlierCount = zeros(I1,I2,I3,I4, numRMSEPoints); % gp outlier counts

    % rmseThresh filtered: history cell, means & outliers arrays
    rmseThreshFGHC = SetupGSDataCell(hyperparamGrid);           % history cell
    filteredRMSEThreshGPM = -ones(I1,I2,I3,I4, numRMSEThresh);  % gp filtered means
    rmseThreshOutlierCount = zeros(I1,I2,I3,I4, numRMSEThresh); % gp outlier counts

    % relerrPoints filtered: history cell, means & outliers arrays
    relerrPointFGHC = SetupGSDataCell(hyperparamGrid);              % history cell
    filteredRelerrPointGPM = -ones(I1,I2,I3,I4, numRelerrPoints);  % gp filtered means
    relerrPointOutlierCount = zeros(I1,I2,I3,I4, numRelerrPoints); % gp outlier counts

    % relerrThresh filtered: history cell, means & outliers arrays
    relerrThreshFGHC = SetupGSDataCell(hyperparamGrid);              % history cell
    filteredRelerrThreshGPM = -ones(I1,I2,I3,I4, numRelerrThresh);  % gp filtered means
    relerrThreshOutlierCount = zeros(I1,I2,I3,I4, numRelerrThresh); % gp outlier counts

% FOR each reservoir size
for i1=1:I1
%-% FOR each winScalar
    for i2=1:I2
%-----% FOR each spectral radius
        for i3=1:I3
%---------% FOR each leaking rate
            for i4=1:I4
%---------% 1) REMOVE OUTLIERS & SORT GPM target pairs (benchmarkParam, mean)

                % 1.1 RMSEPOINTS
                % rmsePoint: pair with outlier count & filtered mean
                rmsePointFGHC{i1}{i2}{i3}{i4} = cell(1,numRMSEPoints);  % history cell
                pairsRMSEPoint = [];
                for j=1:numRMSEPoints
                    allVals = rmsePointGHC{i1}{i2}{i3}{i4}(:,j); % get all data
                    outlierIndex = isoutlier(allVals);           % find outliers
                    outlierCount = sum(outlierIndex);            % # outliers
                    rmsePointOutlierCount(i1,i2,i3,i4,j) = outlierCount; % record # outliers
                    % get mean without outliers
                    filteredVals = allVals(~outlierIndex);                    % remove outlires
                    filteredRMSEPointGPM(i1,i2,i3,i4,j) = mean(filteredVals); % new mean
                    % pair [used later]: rmsePoint(j) | #outliers | filtered mean
                    pairsRMSEPoint = [pairsRMSEPoint,...
                                    rmsePoints(j), outlierCount,...
                                    filteredRMSEPointGPM(i1,i2,i3,i4,j)];
                    % update filtered history cell
                    rmsePointFGHC{i1}{i2}{i3}{i4}{j} = [...
                        hyperparamGrid.reservoirSizeVect(i1),...    % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...        % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),...   % spectralRadius
                        hyperparamGrid.leakingRateVect(i4),...      % leakingRate
                        rmsePoints(j),...                       % rmsePoint(j)
                        outlierCount,...                        % # outliers
                        filteredVals']; % rmse (without outliers, # as col vect) 
                end
                % 1.2 RMSETHRESH
                % rmseThresh: pair with outlier count & filtered mean
                rmseThreshFGHC{i1}{i2}{i3}{i4} = cell(1,numRMSEThresh); % history cell
                pairsRMSEThresh = [];
                for j=1:numRMSEThresh
                    allVals = rmseThreshGHC{i1}{i2}{i3}{i4}(:,j); % get all data
                    outlierIndex = isoutlier(allVals);            % find outliers
                    outlierCount = sum(outlierIndex);             % # outliers
                    rmseThreshOutlierCount(i1,i2,i3,i4,j) = outlierCount; % record # outliers
                    % get mean without outliers
                    filteredVals = allVals(~outlierIndex);                     % remove outliers
                    filteredRMSEThreshGPM(i1,i2,i3,i4,j) = mean(filteredVals); % new mean
                    % pair [used later]: rmseThresh(j) | #outliers | filtered mean
                    pairsRMSEThresh = [pairsRMSEThresh,...
                                    rmseThresh(j), outlierCount,...
                                    filteredRMSEThreshGPM(i1,i2,i3,i4,j)];
                    % update filtered history cell            
                    rmseThreshFGHC{i1}{i2}{i3}{i4}{j} = [...
                        hyperparamGrid.reservoirSizeVect(i1),...    % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...        % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),...   % spectralRadius
                        hyperparamGrid.leakingRateVect(i4),...      % leakingRate
                        rmseThresh(j),...                       % rmseThesh(j)
                        outlierCount,...                        % # outliers
                        filteredVals']; % thresh time (without outliers, # as col vect)
                end
                % 1.3 PERCENTPOINTS
                % relerrPoints: pair with outlier count & filtered mean
                relerrPointFGHC{i1}{i2}{i3}{i4} = cell(1,numRelerrPoints); % history cell
                pairsRelerrPoint = [];
                for j=1:numRelerrPoints
                    allVals = relerrPointGHC{i1}{i2}{i3}{i4}(:,j); % get all data
                    outlierIndex = isoutlier(allVals);              % find outliers
                    outlierCount = sum(outlierIndex);               % # outliers
                    relerrPointOutlierCount(i1,i2,i3,i4,j) = outlierCount; % record # outliers
                    % get mean without outliers
                    filteredVals = allVals(~outlierIndex);                       % remove outliers
                    filteredRelerrPointGPM(i1,i2,i3,i4,j) = mean(filteredVals); % new mean
                    % pair [used later]: relerrPoint(j) | #outliers | filtered mean
                    pairsRelerrPoint = [pairsRelerrPoint,...
                                        relerrPoints(j), outlierCount,...
                                        filteredRelerrPointGPM(i1,i2,i3,i4,j)];
                    % update filtered history cell
                    relerrPointFGHC{i1}{i2}{i3}{i4}{j} = [...
                        hyperparamGrid.reservoirSizeVect(i1),...    % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...        % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),...   % spectralRadius
                        hyperparamGrid.leakingRateVect(i4),...      % leakingRate
                        relerrPoints(j),...                    % relerrPoints(j) 
                        outlierCount,...                        % # outliers
                        filteredVals']; % relerr (without outliers, # as col vect)
                end
                % 1.4 PERCENTTHRESH
                % relerrThresh: pair with outlier count & filtered mean
                relerrThreshFGHC{i1}{i2}{i3}{i4} = cell(1,numRelerrThresh); % history cell
                pairsRelerrThresh = [];
                for j=1:numRelerrThresh
                    allVals = relerrThreshGHC{i1}{i2}{i3}{i4}(:,j); % get all data
                    outlierIndex = isoutlier(allVals);               % find outliers
                    outlierCount = sum(outlierIndex);                % # outliers
                    relerrThreshOutlierCount(i1,i2,i3,i4,j) = outlierCount; % record # outliers
                    % get mean without outliers
                    filteredVals = allVals(~outlierIndex);                        % remove outliers
                    filteredRelerrThreshGPM(i1,i2,i3,i4,j) = mean(filteredVals); % new mean
                    % pair [used later]: relerrThresh(j) | #outliers | filtered mean
                    pairsRelerrThresh = [pairsRelerrThresh,...
                                    relerrThresh(j), outlierCount,...
                                    filteredRelerrThreshGPM(i1,i2,i3,i4,j)];
                    % update filtered history cell
                    relerrThreshFGHC{i1}{i2}{i3}{i4}{j} = [...
                        hyperparamGrid.reservoirSizeVect(i1),...    % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...        % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),...   % spectralRadius
                        hyperparamGrid.leakingRateVect(i4),...      % leakingRate
                        relerrThresh(j),...                    % relerrThresh(j)
                        outlierCount,...                        % # outliers
                        filteredVals']; % relerr thresh time (without outliers, # as col vect)
                end
                
%---------% 2) RECORD MAIN ARRAYS DATA - WITHOUT OUTLIERS
                % gridsearchFRA; column |.| context as follows:
                % reservoirSize | winScalar | spectralRadius | leakingRate
                % mean training time                         |
                % pairs: rmsePoint(j),      mean(rmse(j))    |
                % pairs: rmseThresh(j),     mean(time(j))    |
                % pairs: relerrPoint(j),   mean(relerr(j)) |
                % pairs: relerrThresh(j),  mean(time(j))    |
                GMRAFiltered = [GMRAFiltered;
                    hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                    hyperparamGrid.winScalarVect(i2),...      % winScalar
                    hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                    hyperparamGrid.leakingRateVect(i4),...    % leakingRate
                    pairsRMSEPoint,...                    % pairs: rmsePoints & mean rmse
                    pairsRMSEThresh,...                   % pairs: rmseThresh & mean time
                    pairsRelerrPoint,...                 % pairs: relerrPoints & mean relerr 
                    pairsRelerrThresh];                  % pairs: relerrThresh & mean time
               
            end
        end
    end
end

% FILTERED OPTIMAL RESULTS STRUCTS
% struct: rmsePoints results without outliers
RMSEPoints = struct(...
    'rmsePoints', rmsePoints,...
    'meanValue', reshape(filteredRMSEPointGPM(1,1,1,1,:),[1,numRMSEPoints]),...
    'optimalGP', -ones(numRMSEPoints,length(fieldnames(hyperparamGrid))),...
    'optimalIndex',ones(numRMSEPoints,length(fieldnames(hyperparamGrid))),...
    'outlierCount', reshape(rmsePointOutlierCount(1,1,1,1,:),[1,numRMSEPoints]));
% struct: rmseThresh results without outliers
RMSEThresh = struct(...
    'rmseThresh', rmseThresh,...
    'meanValue',reshape(filteredRMSEThreshGPM(1,1,1,1,:),[1,numRMSEThresh]),...
    'optimalGP',-ones(numRMSEThresh,length(fieldnames(hyperparamGrid))),...
    'optimalIndex',ones(numRMSEThresh,length(fieldnames(hyperparamGrid))),...
    'outlierCount', reshape(rmseThreshOutlierCount(1,1,1,1,:),[1,numRMSEThresh]));
% struct: relerrPoint results without outliers
RelerrPoints = struct(...
    'relerrPoints', relerrPoints,...
    'meanValue',reshape(filteredRelerrPointGPM(1,1,1,1,:),[1,numRelerrPoints]),...
    'optimalGP',-ones(numRelerrPoints,length(fieldnames(hyperparamGrid))),...
    'optimalIndex',ones(numRelerrPoints,length(fieldnames(hyperparamGrid))),...
    'outlierCount', reshape(relerrPointOutlierCount(1,1,1,1,:),[1,numRelerrPoints]));
% struct: relerrThresh result without outlier
RelerrThresh = struct(...
    'relerrThresh', relerrThresh,...
    'meanValue', reshape(filteredRelerrThreshGPM(1,1,1,1,:),[1,numRelerrThresh]),...
    'optimalGP', -ones(numRelerrThresh, length(fieldnames(hyperparamGrid))),...
    'optimalIndex', ones(numRelerrThresh, length(fieldnames(hyperparamGrid))),...
    'outlierCount', reshape(relerrThreshOutlierCount(1,1,1,1,:),[1,numRelerrThresh]));

% FIND OPTIMAL PARAMS WITHOUT OUTLIERS

% FOR each reservoir size
for i1=1:I1
%-% FOR each winScalar
    for i2=1:I2
%-----% FOR each spectralRadius
        for i3=1:I3
%---------% FOR each leakingRate
            for i4=1:I4
%---------% 1) FIND OPTIMAL RESULT AT EACH GRIDPOINT (GP)
                % 1.1 RMSEPOINT
                % minimum mean rmse at gp for each rmsePoint
                for j=1:numRMSEPoints
                if filteredRMSEPointGPM(i1,i2,i3,i4,j) <= RMSEPoints.meanValue(j) % check if optimal mean rmse
                    RMSEPoints.meanValue(j) = ...
                        filteredRMSEPointGPM(i1,i2,i3,i4,j);      % update value
                    RMSEPoints.optimalIndex(j,:) = [i1,i2,i3,i4]; % update index
                    RMSEPoints.optimalGP(j,:) = [...          % new optimal point
                        hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...      % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                        hyperparamGrid.leakingRateVect(i4)];      % leakingRate
                    RMSEPoints.outlierCount(j) = rmsePointOutlierCount(i1,i2,i3,i4,j); % # outliers
                end
                end
                % 1.2 RMSETHRESH
                % maximum mean forecast time at gp for each rmseThresh
                for j=1:numRMSEThresh
                if filteredRMSEThreshGPM(i1,i2,i3,i4,j) >= RMSEThresh.meanValue(j) % check if optimal mean time
                    RMSEThresh.meanValue(j) = ...
                        filteredRMSEThreshGPM(i1,i2,i3,i4,j);     % update value
                    RMSEThresh.optimalIndex(j,:) = [i1,i2,i3,i4]; % update index
                    RMSEThresh.optimalGP(j,:) = [...          % new optimal point
                        hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...      % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                        hyperparamGrid.leakingRateVect(i4)];      % leakingRate
                    RMSEThresh.outlierCount(j) = rmseThreshOutlierCount(i1,i2,i3,i4,j); % # outliers
                end
                end                
                % 1.3 PERCENTPOINT
                % minimum mean relerr at gp for each relerrPoint
                for j=1:numRelerrPoints
                if filteredRMSEPointGPM(i1,i2,i3,i4,j) <= RelerrPoints.meanValue(j) % check if optimal mean relerr
                    RelerrPoints.meanValue(j) = ...
                        filteredRMSEPointGPM(i1,i2,i3,i4,j);         % update value
                    RelerrPoints.optimalIndex(j,:) = [i1,i2,i3,i4]; % update index
                    RelerrPoints.optimalGP(j,:) = [...        % new optimal point
                        hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...      % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                        hyperparamGrid.leakingRateVect(i4)];      % leakingRate
                    RelerrPoints.outlierCount(j) = relerrPointOutlierCount(i1,i2,i3,i4,j); % # outliers
                end
                end
                % 1.4 PERCENTTHRESH
                % maximum mean forecast time at gp for each relerrThresh
                for j=1:numRelerrThresh
                if filteredRelerrThreshGPM(i1,i2,i3,i4,j) >= RelerrThresh.meanValue(j) % check if optimal mean time
                    RelerrThresh.meanValue(j) = ...
                        filteredRelerrThreshGPM(i1,i2,i3,i4,j);     % update value
                    RelerrThresh.optimalIndex(j,:) = [i1,i2,i3,i4]; % update index
                    RelerrThresh.optimalGP(j,:) = [...       % new optimal point
                        hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...      % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                        hyperparamGrid.leakingRateVect(i4)];      % leakingRate
                    RelerrThresh.outlierCount(j) = relerrThreshOutlierCount(i1,i2,i3,i4,j); % # outliers
                end
                end
                
            end
        end
    end
end

% store results as struct
OptimalGSParamsFiltered = struct(...
    'RMSEPoints', RMSEPoints,...
    'RMSEThresh', RMSEThresh,...
    'RelerrPoints', RelerrPoints,...
    'RelerrThresh',RelerrThresh);