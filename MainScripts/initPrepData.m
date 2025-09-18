% PREPARE DATASETS
% Load/Generate Data

dt = 0.02;      % time-step (for continuous system)
numBatches = 1; % split data into batches - helps with memory (large X)
washout = 100;  % default initial transient (washout)

% Alternative: time steps in Lyapunov time
%   set dt to fraction of lyapunov time;
%   e.g. 5 Lyapunov times : dt=lt/N -> 5N*dt
% Alternative 2: increase/decrease dt w.r.t. difference in MLE/LT

% SIMPLE SYSTEM: Constant Line
% U = 1*ones(1,1.3e4+1);   % y = 1
% %U = 10*ones(1,1.3e4+1);  % y = 10
% t = dt.*(0:1:1.3e4);     % time
% LyapunovTime = 1;      % n/a, just for plots

% SIMPLE SYSTEM: Ellipse
% [t, U] = genSystemEllipse(dt, 2e4, 0,[]); U=U'; % Circle (a=b=1)
% [t, U] = genSystemEllipse(dt, 3e4, 0, [1,4]); U=U'; % ellipse (a=1,b=4)
% LyapunovTime = 1/pi;  % pi-period (not Lyapunov time)

% APERIODIC WAVE
% Y(t) = Cos(t) + Sin(sqrt(2)*t);
% [t, U] = genSystemSinCosSum(dt, 2e4, 0, 1, sqrt(2));
% LyapunovTime = 1/pi;  % pi-period (not Lyapunov time)

% CUSTOM APERIODIC 3D SYSTEM
% [t, U] = getSystemCustAp3D(dt, 1e4, pi/2); U=U'; % ic=0 at origin
% LyapunovTime = 1/pi;

% RANDOM NOISE
% U = randn(1,1.2e4+1);     % Gaussian Noise
% U = rand(1,1.2e4+1);      % Uniform [0,1]
% t = dt.*(0:1:length(U));  % time
% LyapunovTime = 1;      % n/a, just for plots

% HENON MAP
% Henon Map | Lyapunov exponents ~ [0.41922, -1.62319]
%           | Lyapunov time: 1/0.41922 = 2.3854 -> how to translate to int?
% [t, U] = genMapHenon(2e4, [0,0.9], [1.4, 0.3]);

% CHIRIKOV STANDARD MAP
% Chirikov Standard Map | Lyapunov exponents ~ [+0.10497, -0.10497]
%                       | Lyapunov time: 1/0.10497 = 9.5265
% [t, U] = genMapChirikov(1.3e4, [0, 6], [1]);

% LORENZ SYSTEM
% Lorenz | Lyapunov exponents ~ [0.9056, 0, -14.5723]
%        | Lyapunov time: 1/0.9056 ~ 1.1042
tic;
[t, U] = genSystemLorenz(dt, 1.3e4, [1,1,1], [10, 8/3, 28]); % 2e4...
toc
LyapunovTime = 1.1042;
% Lorenz: use to find time indices w.r.t. Lyapunov time
% find(t(t<=LyapunovTime),1,'last')+1 | Ltime [57, 112, 222, 443, 885] for dt=0.02;

% ROSSLER SYSTEM
% Rossler | Lyapunov exponents ~ [0.0714, 0, -5.3943]
%         | Lyapunov time: 1/0.0714 ~ 14.0056
% tic
% [t, U] = genSystemRossler(dt, 2.5e4, [-9,0,0], [0.2,0.2,5.7]);
% toc
% LyapunovTime = 14.0056;
% Rossler: use to find time indices w.r.t. Lyapunov time
% find(t(t<=LyapunovTime),1,'last')+1 | Ltime [702, 1402, 2803, 5604, 11206] for dt=0.02;

% LIU SYSTEM
% Liu     | Lyapunov exponents ~ [1.64328, 0, -14.142]  % LIU2004 paper
%         | Lyapunov time: 1/1.64328 ~ 0.6085
% tic
% [t, U] = genSystemLiu(dt, 1.4e4, [2.2,2.4,38], [10,40,1,2.5,4]); % Liu
% toc
% LyapunovTime = 0.6085;
% Liu: use to find time indices w.r.t. Lyapunov time
% find(t(t<=LyapunovTime),1,'last')+1 | Ltime [32, 62, 245, 488, 975] for dt=0.02;

%% Recover Data
% U = Data.U;
% t = Data.t;
% dt = Data.dt;
% clear Data

% window length L=0->[u(1)], L=1->[u(1),u(2)]
% so L=L -> [u(1),...,u(L+1)]
windowLength = 0; % no transformation when 0
U = transform2window(U,windowLength); % (not used)

% DIMENSIONS
inDim = size(U,1); outDim = inDim; % assume forecasting u(t)->u(t+1)
ioDims = [inDim, outDim];
dataLength = size(U,2);

% SPLIT LENGTH | Train 70 / Test 30 (not used)
splitRatio = 0.7;
trainLength = floor(splitRatio*dataLength);
testLength = dataLength - trainLength -1;

% SPLIT LENGTH | Fixed Train = 1e4, variable Train
trainLength = 1e4; % for dt=0.02, rescaled to match dt=0.01
testLength = dataLength - trainLength - 1;

% TRAIN SPLIT
trainU = U(:,1:trainLength);    % -T:-1
trainY = U(:,2:trainLength+1);  % -T-1:0

% TEST SPLIT
testU = U(:,trainLength+1:trainLength+testLength);
testY = U(:,trainLength+2:trainLength+testLength+1);

% NEEDS ADDITIONAL STEPS FOR FORECASTING
%   e.g., extract forecast Uy at step T
%   then push it into Ux window for step T+1
% 
% windowLength = 3;
% [Ux, Uy] = transform2window2one(U, windowLength);
% trainU = Ux(:,1:trainLength);
% trainY = Uy(:,1:trainLength);
% testU = Ux(:,trainLength+1:trainLength+testLength-10);
% testY = Uy(:,trainLength+1:trainLength+testLength-10);
% ioDims = [size(testU,1), size(testY,1)];
% 

%% Plot Lorenz | plot figure
% [~, U] = genSystemLorenz(0.01, 1.3e4, [1,1,1], [10, 8/3, 28]);
% endPoint = 1e4;
% plot3(U(1,1:endPoint),U(2,1:endPoint),U(3,1:endPoint),'-k')
% view(180,0)
% axis equal square; axis off

%% Plot Henon | plot figure
% [~, U2] = genMapHenon(2e4, [0,0.9], [1.4, 0.3]);
% plot(U2(1,:),U2(2,:),'.k')
% axis equal square; axis off

