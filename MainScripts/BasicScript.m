rng(42); % fix RNG

% Params (data comes from initPrepData.m by default)
% washout = 100;
% numBatches = 10;

% ESN HYPERPARAMETERS
DefineHyperparameters;
hyperparameters.reservoirSize = 1000; % ESN size (N)
hyperparameters.winScalar = 0.1;      % Win scalar (eta)
hyperparameters.spectralRadius = 1.0; % reservoir spectral radius (rho)
hyperparameters.leakingRate = 0.75;   % leaking rate (alpha)

hyperparameters.rrCoeff = 1e-8;       % ridge-regression coeff (beta)
hyperparameters.activation = 'tanh';
    %   tanh / sigmoid / relu / leakyrelu / gaussian / softplus
    %   binarystep / silu / id / selu/ gelu / softmax

% only if these are not defined
if ~exist('washout'); washout = 0; end  % washout lenght (undefined=none)
if ~exist('numBatches'); numBatches = 1; end % num batches (for large T)

% Training Benchmark Parameters (to find best ESN)
GenESNThreshParams = struct('threshValue', 0.001,...         % error threshold value
                         'threshType', 'relerr',...          % threshold type: rmse/relerr
                         'targetPerformance', testLength,... % target performance (length)
                         'numAttempts',3,...                 % # attempts
                         'keepTrainingState',true,...        % keep pre-forecast esn state
                         'printTrainingOutcome',true);       % print training outcome (performance)

% Training Parameters (main)
% add everything to struct for convenience (outdated)
Params = struct(...
    'GenESNThreshParams', GenESNThreshParams,...
    'reservoirSizeVect', hyperparameters.reservoirSize,...
    'hyperparameters', hyperparameters,...
    'numSamples', 1,...     % not needed here
    'washout', washout);

%% TRAIN THE ESN
% train the ESN for given training data
tic
[esn, ESNPerformanceResults] = GenerateMeanThreshESN(...
    hyperparameters, washout,...
    trainU, trainY, testU, testY, numBatches, GenESNThreshParams);
toc

%% Store Test Params
origWout = esn.Wout; % remember the original
origState = esn.x;

%% Eigenvalue Decomposition Method (e.d.)
% comment out if not used. replace usual rr output weights training with
% e.d. of (XX'+beta*I) or simple (XX')...

%     % e.d. for rr solver (MAIN)
%     [V, D] = eig(esn.matXX + ...
%                  esn.hyperparameters.rrCoeff*eye(length(esn.matXX)));
%     % e.d. for simple solver option
%     % [V, D] = eig(esn.matXX);
% 
%     % Compute output weights
%     edWout = (esn.matYX*V) * (D)^-1 * V';
%     % esn.Wout = edWout; % replace Wout
% 
%     % Option to 'turn off' eigenstates
%     %V(:,1:100) = 0; % column = estate, ascending evals (last is largest)
% 
%     % alternative eigsntstate control: set (D)^-1 diags to 0
%     % D = D^-1; D(1:100,1:100) = 0; % working with V is easier
% 
% % "Projections" YX*V and D^-1 * V';
% if exist("V",'var')
%     projA = esn.matYX*V; % YX'V project data on eigenstates
%     scalarB = (D)^-1 * V'; % "scaled eigenstates" (s.e.)
% end

%% Plot Param Settings
% Slightly complicated setup to automatically plot some of the results
dim = struct('t',[], 'x',1, 'y',2, 'z',3);  % plot-dims (up to 3D)
PlotParams = struct('addGrid', true,...   %
                    'minorGrid', true,... %
                    'fixXAxis', true,...  %
                    'fixYAxis', true,...  %
                    'fixZAxis', true,...  %
                    'LineWidth', 3);      %

%% Other Plot Params
% important plot parameters
% Ensure that forecastTime<=testLength (to compute error)

dimCheck = dim.x; % default: plot x-axis (for NDim plots)

zoomTime = 443;       % length (index, change manually)
rmseThresh = 0.01;    % threshold line (for plots) 
relerrThresh = 0.001; % threshold line (for plots)

forecastStartTime = 1; % 1=continue directly from training
forecastTime = 3e3;    % up to testLength for Performance Metrics
forecastEndTime = forecastStartTime+forecastTime-1;

% timescale settings (for plots)
if ~exist("dt",'var'); dt=1; end
if ~exist("LyapunovTime",'var'); LyapunovTime=1; end

trainTimeVar = dt*(washout-trainLength:1:-1)/LyapunovTime;
testTimeVar = dt*(forecastStartTime:1:forecastEndTime)/LyapunovTime;

%% FORECASTING: NEW I.C. / Washout
% additional washout=100, ensure to adjust trueY data to account for
% washout and forecsatStartTime!
% esn.Washout(testU(:,900:1000), 100);

% main forecast
forecastY = esn.Forecast(testU(:,forecastStartTime), forecastTime);
% forecast with history (activation X matrix generated during forecast)
%[forecastY, forecastX] = esn.ForecastWithHistory(testU(:,forecastStartTime), forecastTime);

% true/target data for forecasting
trueY = testY(:,forecastStartTime:forecastEndTime);

%% PERFORMANCE / ERRORS
[rmseSeries, intensitySeries, relerrSeries] = ...
    ESNPerformanceSeries(trueY, forecastY);

% get info on threshold errors
relerrIndex = find(relerrSeries>Params.GenESNThreshParams.threshValue,1);
rmseIndex = find(rmseSeries>Params.GenESNThreshParams.threshValue,1);
if isempty(relerrIndex); relerrIndex = length(testU); end % below thresh
if isempty(rmseIndex); rmseIndex = length(testU); end % below thresh

fprintf('<strong>THRESHOLD FORECAST</strong>\n')
fprintf('relerr len\t %5d\t with %.5e\n',relerrIndex, relerrSeries(relerrIndex))
fprintf('rmse len\t %5d\t with %.5e\n', rmseIndex, rmseSeries(rmseIndex))

%% MAIN FORECAST PLOT
figure; hold on;
switch size(forecastY,1)
    case 1 % 1D plot
        plot(testTimeVar,forecastY(1,:),'r'); % forecast
        plot(testTimeVar,trueY(1,:),'b');     % true
    case 2 % 2D plot
        plot(forecastY(1,:),forecastY(2,:),'r'); % forecast
        plot(trueY(1,:),trueY(2,:),'b');         % true
    case 3 % 3D plot
        plot3(forecastY(1,:),forecastY(2,:),forecastY(3,:)); % forecast
        plot3(trueY(1,:),trueY(2,:),trueY(3,:));             % true
end

%% PLOT 1D
% built-in plot for dimCheck axis (x-axis by default)
% simple plots of true signal, forecast, and comparison
PlotComparison1D(testTimeVar(1:forecastTime), testY(dimCheck,forecastStartTime:forecastEndTime),...
                              forecastY(dimCheck,1:forecastTime), PlotParams);   

%% PERFORMANCE / ERROR SIMPLE PLOTS
% simple subplots for rmse and relerr
figure;
subplot(1,2,1);
    plot(testTimeVar,rmseSeries); % rmse
    ylabel('rmse'); xlabel('t'); title('forecast rmse')
subplot(1,2,2);
    plot(testTimeVar,relerrSeries); %relerr
    ylabel('relerr'); xlabel('t'); title('forecast relerr')

%% DIFFERENCE PLOT
% built-in plot of "difference": diff = true-forecast
% shows how 'close' the forecast is, includes an errTime zoomin
PlotDifference(testTimeVar, testY(:,forecastStartTime:forecastEndTime),...
    forecastY, zoomTime, PlotParams)

%% DISTANCE PLOT
% built-in plot of "distance": dist = sqrt(true^2 - forecast^2)
% shows how 'close' the forecast is, includes an errTime zoomin
PlotDistance(testTimeVar, testY(:,forecastStartTime:forecastEndTime),...
    forecastY, zoomTime, PlotParams)

%% RATIO PLOT
% built-in plot of "ratio": rat = forecast/true (y/0 ~ inf)
% shows the ratio, with rat~1 implying good performance, highlights
% "spikes" in error, and includes an errTime zoomin
ratioType = "distance"; % setting to deal with pos/neg sign
PlotRatio(testTimeVar, testY(:,forecastStartTime:forecastEndTime),...
    forecastY, zoomTime, PlotParams, ratioType)

%% RMSE PLOT
% built-in plot for RMSE, includes zoomin
PlotRMSE(testTimeVar, testY(:,forecastStartTime:forecastEndTime),...
    forecastY, zoomTime, rmseThresh, PlotParams)
%% RELERR PLOT
% built-in plot for Relative Error, includes zoomin
PlotRelerr(testTimeVar, testY(:,forecastStartTime:forecastEndTime),...
    forecastY, zoomTime, relerrThresh, PlotParams)

%% ACTIVATIONS PLOT
% built-in plot for ESNs activations
% PlotEchoes(..., ..., timeRange, rowRange, PlotParams)
% use timeRange to zoom into time interval, and rowRange to plot certain
% reservoir states. First "1+ioDims(1)" rows are for bias+signal

PlotEchoes(trainTimeVar, esn.X, [1:length(trainTimeVar)], [10:14], PlotParams);
%PlotEchoes(trainTimeVar, esn.X, [1:length(trainTimeVar)], [5:1004], PlotParams);