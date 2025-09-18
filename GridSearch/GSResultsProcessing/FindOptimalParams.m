function [OptimalGSParams] = FindOptimalParams(hyperparamGrid, benchmarkParams,...
                                 rmsePointGPM, rmseThreshGPM,...
                                 relerrPointGPM, relerrThreshGPM)
% FindOptimalParams
% Go through the rmse/relerr point/thresh GPM arrays and find the
% gridpoint with best performance for each benchmark category
%   *) Works with MEAN values
%   *) Includes outliers
%
% Use "FilterGridsearchOutliers.m" for optimal GP without outliers
%
% ACRONYMS: check GridsearchScript.m allocation

% counters
    I1 = length(hyperparamGrid.reservoirSizeVect);  % # reservoir sizes
    I2 = length(hyperparamGrid.winScalarVect);      % # winScalars
    I3 = length(hyperparamGrid.spectralRadiusVect); % # spectral radii
    I4 = length(hyperparamGrid.leakingRateVect);    % # leaking rates

% benchmarkParams
    rmsePoints = benchmarkParams.rmsePoints;       % rmse points
    rmseThresh = benchmarkParams.rmseThresh;       % rmse thresh
    relerrPoints = benchmarkParams.relerrPoints; % relerr points
    relerrThresh = benchmarkParams.relerrThresh; % relerr thresh

% # points of interest    
    numRMSEPoints = size(rmsePoints,2);       % # rmse points
    numRMSEThresh = size(rmseThresh,2);       % # rmse thresh
    numRelerrPoints = size(relerrPoints,2); % # relerrPoints
    numRelerrThresh = size(relerrThresh,2); % # relerrThresh

% struct: rmsePoints results
RMSEPoints = struct(...
    'rmsePoints',   rmsePoints,...
    'meanValue', reshape(rmsePointGPM(1,1,1,1,:),[1,numRMSEPoints]),...
    'optimalGP',    -ones(numRMSEPoints,length(fieldnames(hyperparamGrid))),...
    'optimalIndex', ones(numRMSEPoints,length(fieldnames(hyperparamGrid))));
% struct: rmseThresh results
RMSEThresh = struct(...
    'rmseThresh',   rmseThresh,...
    'meanValue', reshape(rmseThreshGPM(1,1,1,1,:),[1,numRMSEThresh]),...
    'optimalGP',    -ones(numRMSEThresh,length(fieldnames(hyperparamGrid))),...
    'optimalIndex', ones(numRMSEThresh,length(fieldnames(hyperparamGrid))));
% struct: relerrPoints results
RelerrPoints = struct(...
    'relerrPoints', relerrPoints,...
    'meanValue',  reshape(relerrPointGPM(1,1,1,1,:),[1,numRelerrPoints]),...
    'optimalGP',     -ones(numRelerrPoints,length(fieldnames(hyperparamGrid))),...
    'optimalIndex',  ones(numRelerrPoints,length(fieldnames(hyperparamGrid))));
% struct: relerrThresh results
RelerrThresh = struct(...
    'relerrThresh', relerrThresh,...
    'meanValue',  reshape(relerrThreshGPM(1,1,1,1,:),[1,numRelerrThresh]),...
    'optimalGP',     -ones(numRelerrThresh, length(fieldnames(hyperparamGrid))),...
    'optimalIndex',  ones(numRelerrThresh, length(fieldnames(hyperparamGrid))));

% FOR each reservoirSize
for i1=1:I1
%-% FOR each winScalar
    for i2=1:I2
%-----% FOR each spectralRadius
        for i3=1:I3
%---------% FOR each leakingRate
            for i4=1:I4
%---------% 1) FIND OPTIMAL RESULT AT EACH GRIDPOINT (GP)
                % 1.1 RMSE at point
                % minimum mean rmse at gp for each rmsePoint
                for j=1:numRMSEPoints
                if rmsePointGPM(i1,i2,i3,i4,j) <= RMSEPoints.meanValue(j)  % check if optimal mean rmse
                    RMSEPoints.meanValue(j) = rmsePointGPM(i1,i2,i3,i4,j); % update value
                    RMSEPoints.optimalIndex(j,:) = [i1,i2,i3,i4];          % update index
                    RMSEPoints.optimalGP(j,:) = [...          % new optimal point
                        hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...      % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                        hyperparamGrid.leakingRateVect(i4)];      % leakingRate
                end
                end
                % 1.2 RMSE THRESH (time/length)
                % maximum mean forecast time at gp for each rmseThresh
                for j=1:numRMSEThresh
                if rmseThreshGPM(i1,i2,i3,i4,j) >= RMSEThresh.meanValue(j)  % check if optimal mean time
                    RMSEThresh.meanValue(j) = rmseThreshGPM(i1,i2,i3,i4,j); % update value
                    RMSEThresh.optimalIndex(j,:) = [i1,i2,i3,i4];           % update index
                    RMSEThresh.optimalGP(j,:) = [...          % new optimal point
                        hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...      % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                        hyperparamGrid.leakingRateVect(i4)];      % leakingRate
                end
                end
                % 1.3 PERCENT at point
                % minimum mean relerr at gp for each relerrPoint
                for j=1:numRelerrPoints
                if relerrPointGPM(i1,i2,i3,i4,j) <= RelerrPoints.meanValue(j)  % check if optimal mean relerr
                    RelerrPoints.meanValue(j) = relerrPointGPM(i1,i2,i3,i4,j); % update value
                    RelerrPoints.optimalIndex(j,:) = [i1,i2,i3,i4];             % update index
                    RelerrPoints.optimalGP(j,:) = [...        % new optimal point
                        hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...      % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                        hyperparamGrid.leakingRateVect(i4)];      % leakingRate
                end
                end
                % 1.4 PERCENT THRESH (time/length)
                % maximum mean forecast time at gp for each relerrThresh
                for j=1:numRelerrThresh
                if relerrThreshGPM(i1,i2,i3,i4,j) >= RelerrThresh.meanValue(j)  % check if optimal mean time
                    RelerrThresh.meanValue(j) = relerrThreshGPM(i1,i2,i3,i4,j); % update value
                    RelerrThresh.optimalIndex(j,:) = [i1,i2,i3,i4];              % update index
                    RelerrThresh.optimalGP(j,:) = [...       % new optimal point
                        hyperparamGrid.reservoirSizeVect(i1),...  % reservoirSize
                        hyperparamGrid.winScalarVect(i2),...      % winScalar
                        hyperparamGrid.spectralRadiusVect(i3),... % spectralRadius
                        hyperparamGrid.leakingRateVect(i4)];      % leakingRate
                end
                end
                
            end
        end
    end
end

% store results as struct
OptimalGSParams = struct(...
    'RMSEPoints', RMSEPoints,...
    'RMSEThresh', RMSEThresh,...
    'RelerrPoint', RelerrPoints,...
    'RelerrThresh', RelerrThresh);