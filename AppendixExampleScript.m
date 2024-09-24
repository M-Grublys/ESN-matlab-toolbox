%% Sample Matlab code
N = 1e3;     % reservoir size
eta = 0.1;   % Win scalar
rho = 0.9;   % W spectral radius
alpha = 0.5; % leaking rate
beta = 1e-8; % ridge-regression

% Sine wave (arbitrary range)
T = 1e4;    % time-series length
tsTime = linspace(0,exp(pi),T); % time-axis
genData = [sin(tsTime); cos(tsTime)]; % circle
dt = tsTime(2); % time-step
inDim = 2; outDim = 2; % hardcoded

washout = 100;
trainLength = floor(0.7*T);
testLength = T - trainLength -1;

% split data
U = genData(:,1:trainLength);   % train input
Y = genData(:,2:trainLength+1); % train target
testU = genData(:,trainLength+1:end); % test split
testY = genData(:,trainLength+1:trainLength+testLength);

Win = eta*(2*rand(N,inDim+1)-1); % input weights

W = 2*(sprand(N,N,0.05)-1); % sparse uniform reservoir
W = rho/abs(eigs(W,1)) * W; % rescale spectral radius

X = zeros(N+inDim+1,trainLength-washout); % activations time-series
x = zeros(N,1); % reservoir state

% perform initial washout
for t=1:washout
    x = alpha*x + tanh(Win*[1;U(:,t)] + W*x);
end
Y(:,1:washout) = []; % remove washout
U(:,1:washout) = [];

% post-washout training
for t=1:(trainLength-washout)
    x = alpha*x + tanh(Win*[1;U(:,t)] + W*x);
    X(:,t) = [1;U(:,t);x];
end

% find output weights using ridge-regression
Wout = (Y*X') / (X*X' + beta*eye(N+inDim+1));

% prepare for forecast
forecastY = zeros(outDim,testLength);
yhat = testU(:,1); % forecast i.c.

% forecasting
for t=1:testLength
    x = alpha*x + tanh(Win*[1;yhat] + W*x);
    forecastY(:,t) = Wout * [1;yhat;x];
    yhat = forecastY(:,t);
end

%% Compute forecast error

e = dot( (testY-forecastY),(testY-forecastY), 1); % for rmse
intensity = dot( testY, testY, 1); % for relative error
rmseSeries = zeros(1,testLength); % store rmse

intensitySeries = zeros(1,testLength); % store intensity
relerrSeries = zeros(1,testLength); % store relerr series

% compute error at each forecast time-step
for t = 1:testLength
    rmseSeries(t) = sqrt( mean(e(1:t)) ); % rmse
    intensitySeries(t) = sum( intensity(1:t) )./t; % intensity
    relerrSeries(t) = rmseSeries(t) ./ ...
                      sqrt(intensitySeries(t) ); % relerr
end

%% Plot error and forecast

figure;subplot(1,2,1); % plot relative error
    plot(dt*(1:1:testLength), relerrSeries);
subplot(1,2,2); hold on; % plot test signal and forecast
    plot(testY(1,:),testY(2,:),'b');
    plot(forecastY(1,:),forecastY(2,:),'--r');