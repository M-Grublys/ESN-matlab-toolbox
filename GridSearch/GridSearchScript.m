%% GridSearchScript
% Main script file
% perform gridsearch optimisation, at each gridpoint (N,eta,rho,alpha)
% train and test M unique ESNs. record performance:
%   rmse/relerr for fixed-length sequences (error at fixed index)
%   threshold time for defined rmse/relerr (largest index below threshold)
% 
% total number of gridpoints: #N * #eta * #rho * #alpha * #samples
%
% algorhtmic is a set of nested for-loops. by default uses parallelisation
% (parfor) in the most inner (#samples) loop
%
% records gridsearch results in arrays/cells, and prints the optimal
% gridpoint. provides results with and without outliers, but only filtered
% (mean without outliers) are displayed in command window
%   * OptimalGSParams = includes outliers
%   * OptimalGSParamsFiltered = excludes outliers (displayed)
%
% we define optimal gridpoint to be one that has the optimal average value
% (e.g. smallest average rmse or largest threshold time)

%% INIT VARS
% Initialise (most) variables to be used in GS

% counters
    I1 = length(hyperparamGrid.reservoirSizeVect);  % # reservoir sizes
    I2 = length(hyperparamGrid.winScalarVect);      % # winScalars
    I3 = length(hyperparamGrid.spectralRadiusVect); % # spectral radii
    I4 = length(hyperparamGrid.leakingRateVect);    % # leaking rates
    i1 = 0; i2 = 0; i3 = 0; i4 = 0;                 % count index

% waitbar count
    wbarMaxCount = I1*I2*I3*I4; wbarCount = 0;

% benchmarkParams: # points of interest
    numRMSEPoints = size(benchmarkParams.rmsePoints,2);     % # rmsePoints
    numRMSEThresh = size(benchmarkParams.rmseThresh,2);     % # rmseThresh
    numRelerrPoints = size(benchmarkParams.relerrPoints,2); % # relerrPoints
    numRelerrThresh = size(benchmarkParams.relerrThresh,2); % # relerrThresh
    
%% Allocate space for GS results
% ACRONYMS/NOTATION:
%   GPM  = gridsearch gridpoints mean
%   GRA  = gridsearch results array
%   GRC  = gridsearch results cell
%   GHC  = gridsearch history cell
%   HC   = history cell
%   for more check post-gs processing

    % train times
    trainTimeHC = SetupGSDataCell(hyperparamGrid); % all train times per gp
    trainTimeGPM = zeros(I1,I2,I3,I4);             % mean train times per gp
    trainTimeVect = [];
    
    % rmse error at time points
    rmsePointGHC = SetupGSDataCell(hyperparamGrid);  % all rmse per gp
    rmsePointGPM = zeros(I1,I2,I3,I4,numRMSEPoints); % mean rmse per gp
    rmsePointVect = [];
    % threshold times
    rmseThreshGHC = SetupGSDataCell(hyperparamGrid);  % all rmse thresh times per gp
    rmseThreshGPM = zeros(I1,I2,I3,I4,numRMSEThresh); % mean rmse thresh time per gp
    rmseThreshVect = [];
    % relerrage error at points
    relerrPointGHC = SetupGSDataCell(hyperparamGrid);     % all relerrage per gp
    relerrPointGPM = zeros(I1,I2,I3,I4,numRelerrPoints); % mean relerrage per gp
    relerrPointVect = [];
    % relerrage threshold times
    relerrThreshGHC = SetupGSDataCell(hyperparamGrid);      % all % thresh times per gp
    relerrThreshGPM = zeros(I1,I2,I3,I4,numRelerrThresh);  % mean % thresh times per gp
    relerrThreshVect = [];

%% PRE-GRIDSEARCH
% Default hyperparams are defined here. Any non-GS params should be
% (manually) defined here.
hyperparameters = DefaultGridsearchHyperparameters();

% init waitbar
[wbar, wbar_fspec] = GridsearchWaitbar();

%% MAIN GRIDSEARCH LOOP
% Grid points: (winScalar, spectralRadius, leakingRate, resSize, #samples)

% FOR each winScalar
for winScalar = hyperparamGrid.winScalarVect
    i2=i2+1;                               % winScalar index
    hyperparameters.winScalar = winScalar; % update param
%-% FOR each spectral radius
    for spectralRadius = hyperparamGrid.spectralRadiusVect
        i3=i3+1;                                         % spectral radius index
        hyperparameters.spectralRadius = spectralRadius; % update param
%-----% FOR each leaking rate
        for leakingRate = hyperparamGrid.leakingRateVect
            i4=i4+1;                                   % leaking rate index
            hyperparameters.leakingRate = leakingRate; % update param
%---------% FOR each reservoir size
            for reservoirSize = hyperparamGrid.reservoirSizeVect
                i1=i1+1;                                       % reservoir size index                               
                hyperparameters.reservoirSize = reservoirSize; % update param
                % reset temporary storage vectors
%                 trainTimeVect = []; rmsePointVect = [];  rmseThreshVect = [];
%                 relerrPointVect = []; relerrThreshVect = [];
                trainTimeVect = zeros(repeatSearch, 1);
                rmsePointVect = zeros(repeatSearch, numRMSEPoints);
                rmseThreshVect = zeros(repeatSearch, numRMSEThresh);
                relerrPointVect = zeros(repeatSearch, numRelerrPoints);
                relerrThreshVect = zeros(repeatSearch, numRelerrThresh);

               % rng(42);  % fix rng if needed
%--------------% REPEAT # runs, use "for" to remove parallelisation
                parfor m = 1:repeatSearch
                    % MAIN: train & evaluate ESN
                    [trainTimeVect(m,:), rmsePointVect(m,:), rmseThreshVect(m,:),...
                     relerrPointVect(m,:), relerrThreshVect(m,:)] = ...
                        TestGridPoint(...
                            benchmarkParams, hyperparameters, ioDims,...
                            trainU, trainY, testU, testY, numBatches,...
                            washout, testLength);
                end
                
%---------------% RECORD DATA at gridpoints (gp)
                % train times & mean train time at gp
                trainTimeHC{i1}{i2}{i3}{i4} = trainTimeVect;
                trainTimeGPM(i1,i2,i3,i4) = mean(trainTimeVect);
                
                % rmse at gp
                rmsePointGHC{i1}{i2}{i3}{i4} = rmsePointVect;      % all
                rmsePointGPM(i1,i2,i3,i4,:) = mean(rmsePointVect); % mean
                %rmse  threshold time at gp             
                rmseThreshGHC{i1}{i2}{i3}{i4} = rmseThreshVect;      % all
                rmseThreshGPM(i1,i2,i3,i4,:) = mean(rmseThreshVect); % mean
                % relerrage at gp
                relerrPointGHC{i1}{i2}{i3}{i4} = relerrPointVect;      % all
                relerrPointGPM(i1,i2,i3,i4,:) = mean(relerrPointVect); % mean
                % perentage time at gp
                relerrThreshGHC{i1}{i2}{i3}{i4} = relerrThreshVect;      % all
                relerrThreshGPM(i1,i2,i3,i4,:) = mean(relerrThreshVect); % mean
                
                % update waitbar
                wbarCount = wbarCount+1; 
                wbar_string = sprintf(wbar_fspec,wbarCount,wbarMaxCount,...
                    reservoirSize,winScalar,spectralRadius,leakingRate);
                waitbar(wbarCount/wbarMaxCount, wbar,wbar_string);
            end
            i1=0; % reset reservoir size index
        end
        i4=0;     % reset leaking rate index
    end
    i3=0;         % reset spectral radius index
end

% close waitbar
if exist('wbar','var'); close(wbar); clear wbar; end

% clear temp (loop) vars
clear i1 i2 i3 i4 m
clear wbarCount wbarMaxCount wbar_string wbar_fspec
clear winScalar spectralRadius leakingRate reservoirSize

%% POST-GRIDSEARCH
% Process the results (arrays, cells, structs, etc)
% ACRONYMS/NOTATION:
%   GMRA = gridsearch mean results array (all)
%   GMRAFiltered = gridsearch mean results array (without outliers)
%
%   for more check allocation (GPM~mean, GHC~cell)

% Sort raw GS results into arrays & cells
[GMRA, trainTimeGRA,...
 rmsePointGRC, rmseThreshGRC,...
 relerrPointGRC, relerrThreshGRC] ...
          = CreatePerformanceTable(hyperparamGrid, benchmarkParams,...
                                   trainTimeGPM, trainTimeHC,...
                                   rmsePointGPM, rmsePointGHC,...
                                   rmseThreshGPM, rmseThreshGHC,...
                                   relerrPointGPM, relerrPointGHC,...
                                   relerrThreshGPM, relerrThreshGHC);

% RAW Optimal gridsearch hyperparams
[OptimalGSParams] = FindOptimalParams(hyperparamGrid, benchmarkParams,...
                                    rmsePointGPM, rmseThreshGPM,...
                                    relerrPointGPM, relerrThreshGPM); 

% FILTERED Optimal gridsearch params (better judgement if enough samples)
[OptimalGSParamsFiltered,  GMRAFiltered,...
          rmsePointFGHC, rmseThreshFGHC,...
          relerrPointFGHC, relerrThreshFGHC] ...
          = FilterGridsearchOutliers(hyperparamGrid, benchmarkParams,...
                                   rmsePointGHC, rmseThreshGHC,...
                                   relerrPointGHC, relerrThreshGHC);

%% PRINT RESULTS: FILTERED ONLY
% Print GS results in command window
% Replace with "OptimalGSParams.#.#" in each for-loop
% to display unfiltered results (with outliers)

% MEAN RMSE AT POINT (fixed length sequences)
fprintf('\n<strong>FILTERED OPTIMAL MEAN VALUES</strong>\n')
fprintf('\tRMSE Points | Mean Value\n')
for i=1:size(OptimalGSParamsFiltered.RMSEPoints.meanValue,2)
    fprintf('\t%f ',OptimalGSParamsFiltered.RMSEPoints.rmsePoints(i))
    fprintf('\t\t%f\n',OptimalGSParamsFiltered.RMSEPoints.meanValue(i))
end
% MEAN RMSE THRESH (max length below threshold)
fprintf('\tRMSE Thresh | Mean Value\n')
for i=1:size(OptimalGSParamsFiltered.RMSEThresh.meanValue,2)
    fprintf('\t%f ',OptimalGSParamsFiltered.RMSEThresh.rmseThresh(i))
    fprintf('\t\t%f\n',OptimalGSParamsFiltered.RMSEThresh.meanValue(i))
end
% MEAN PERCENT AT POINT (fixed length sequences)
fprintf('\tRelerr Points | Mean Value\n')
for i=1:size(OptimalGSParamsFiltered.RelerrPoints.meanValue,2)
    fprintf('\t%d ',OptimalGSParamsFiltered.RelerrPoints.relerrPoints(i))
    fprintf('\t\t%f\n',OptimalGSParamsFiltered.RelerrPoints.meanValue(i))
end
% MEAN PERCENT THRESH (max length below threshold)
fprintf('\tRelerr Thresh | Mean Value\n')
for i=1:size(OptimalGSParamsFiltered.RelerrThresh.meanValue,2)
    fprintf('\t%f ',OptimalGSParamsFiltered.RelerrThresh.relerrThresh(i))
    fprintf('\t\t%f\n',OptimalGSParamsFiltered.RelerrThresh.meanValue(i))
end