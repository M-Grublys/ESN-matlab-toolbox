classdef ESN < handle
% ESN class
%    
% Author: Mykolas Grublys
% Date: September 2025
% Version: 1.1

properties
    
    name = 'Echo State Network'; % not needed

    % Training Data Properties
    ioDims = [1, 1];  % [inDim, outDim]
    % inDim  = 1;
    % outDim = 1;

    washout = 0; % deals with initial transient
       
    mode = 'forecast';  % classify (cancelled)
    
    % Hyperparameters
    hyperparameters = ESNHyperparameters; % default from class

    % Activation function handle: @(esn) f(esn.values)
    Activate; % tanh, sigmoid, relu (placeholder)
    
    % Weights
    Win double = [];    % input weights
    B double = [];      % bias vector (none by default)
    Wr double = [];     % 'recurrent reservoir'
    Wout double = [];   % output weights (trained)
    % Reservoir States  
    x double = [];      % current reservoir state 
    X double = [];      % activation time-series
    Xy double = [];     % activation time-series (forecast)
    % Data
    u double = [];      % input data:   u(t) vector
    y double = [];      % output data:  F(u(t))=y(t) vector
    
    % Additional 'intermediate' parameters
    matXX double = [];  % XX'
    matYX double = [];  % YX'

    % Solver Strategies
    solverType = 'default'; % default='ridge', other='ed'

    % initialise reservoir state
    initState = 'zeros';    % zeros, rand, randn, or numeric vector
end

methods
    function esn = ESN(varargin)
    % ESN
    % Initialise an Echo State Network
    %
    % esn = ESN('ParamName1',Param1,'ParamName2',Param2,...)
            
        p = inputParser; % deal with varargin

        % ESN Initialisation - Optional Parameters
        addOptional(p,'hyperparameters', ESNHyperparameters);
        addOptional(p,'ioDims', [1, 1]);  % [inDim, outDim]
        % addOptional(p,'inDim',1);
        % addOptional(p,'outDim',1);

        % Methods    
        addOptional(p,'solverType','default');
        addOptional(p,'mode','forecast');
        addOptional(p,'initState','zeros');

        % Cosmetics (not needed)
        addOptional(p,'name',esn.name);

        % parse varargin
        parse(p,varargin{:});
        
        % ESN Initialisation (parse inputs/preset)
        esn.hyperparameters = p.Results.hyperparameters;
        
        esn.ioDims = p.Results.ioDims; % [inDim, outDim]
        % esn.inDim = p.Results.inDim;
        % esn.outDim = p.Results.outDim;

        % Methods
        esn.solverType = p.Results.solverType; % Solve Wout
        esn.mode = p.Results.mode;             % Forecast/Classify
        esn.initState = p.Results.initState;   % initial reservoir state
        % Cosmetics
        esn.name = p.Results.name;
        % Initialise Parameters
        ESNSetup.InputWeights(esn);       % Win
        ESNSetup.Reservoir(esn);          % Wr
        ESNSetup.InitTrainingParams(esn); % matXX=XX' and matYX=YX'
        ESNSetup.SetActivation(esn);      % Activation tanh/sigmoid/relu
    end
    
    function Washout(esn, U, washout)
    % Washout(esn, U, washout)
    % Deal with initial transients of ESNs activation/reservoir states
    % 
    % esn.Washout(U, washout)

        % set reservoir state x(t):
        % array initState=[x0,x1,...,xn], 'rand', 'randn', 'zeros'
        ESNSetup.SetCurrentState(esn,esn.initState);

        % Washout loop
        for t = 1:washout
            esn.u = U(:,t);      % input data
            UpdateStateStep(esn) % x(t) = ...
            % there is no X in washout (not recorded)
        end
    end
    
    function Echoes(esn, U)
    % Echoes(esn, U)
    % Create the activation (X) time-series used in training, length of X
    % is the same as U
    %
    % esn.Echoes(U)

        inDim = esn.ioDims(1);              % inputs dimension
        b = esn.hyperparameters.biasScalar; % bias scalar

        T = size(U,2);  % train time (length)

        % initialise the X ts matrix
        N = esn.hyperparameters.reservoirSize + ...
            esn.hyperparameters.hasBias + inDim;    % size: #rows
        esn.X = zeros(N, T); % allocate space

        % Generate activations ('echoes') time-series X
        for t = 1:T
            esn.u = U(:,t);                 % input data
            UpdateStateStep(esn)            % x(t) = ...
            esn.X(:,t) = [b; esn.u; esn.x]; % append X(:,t)
        end
    end
    
    function UpdateTrainingParams(esn, Y)
    % UpdateTrainingParams(esn, Y)
    % Update/Append parameters, useful for batches
    % matXX = matXX + X*X'; matYX = matYX + Y*X'
    % 
    % UpdateTrainingParams(esn, Y)

        esn.matXX = esn.matXX + esn.X*esn.X';   % XX'
        esn.matYX = esn.matYX + Y*esn.X';       % YX'
    end

    function Y = Classify(esn, u)
    % Classify(esn, u)
    % Use the trained ESN for classification to classify input u
    %   Y is ESNs output, usually a probabilities vector (cancelled)
    %
    % Y = esn.Classify(u)
        esn.u = u;
        b = esn.hyperparameters.biasScalar;
        UpdateStateStep(esn);
        Y = esn.Wout * [ b; esn.u ; esn.x];
    end

    function Y = Forecast(esn, u, T)
    % Forecast(esn, u, T)
    % Use the trained ESN for time-series forecasting to generate a
    % forecast Y, with initial conditions u, and length (time T)
    %   * Applicable to other sequence generation tasks.
    %
    % Y = esn.Forecast(u, T)
        b = esn.hyperparameters.biasScalar; % bias scalar

        Y = zeros(size(u,1),T+1); % initialise forecast time-series length
        Y(:,1) = u;               % i.c. (dropped after loop)

        % forecast loop
        for t = 1:T
            esn.u = Y(:,t);         % value from previous step
            UpdateStateStep(esn)    % x(t) = ...
            Y(:,t+1) = esn.Wout * [ b; esn.u ; esn.x]; % append forecast ts
        end
        Y(:,1)=[];  % discard i.c. (keep only forecast values)
    end
    
    function [Y, X] = ForecastWithHistory(esn, u, T)
    % ForecastWithHistory(esn, u, T)
    % Use the trained ESN for time-series forecasting to generate a
    % forecast Y, with initial conditions u, and length (time T).
    % Also records the activations time-series X generated during forecast
    % Applicable to other sequence generation tasks.
    %   * Y is ESNs output generated sequence
    %   * X is activation time-series generated during training (large)
    %
    % [Y, X] = esn.ForecastWithHistory(u, T)

        inDim = esn.ioDims(1);              % inputs dim
        b = esn.hyperparameters.biasScalar; % bias scalar

        N = esn.hyperparameters.reservoirSize + ...
            inDim + esn.hyperparameters.hasBias;    % X size (# rows)

        Y = zeros(size(u,1),T+1); % initialise forecast time-series length
        X = zeros(N, T);          % initialise activations time-series

        Y(:,1) = u;     % i.c. (dropped after loop)

        % forecast loop
        for t = 1:T
            esn.u = Y(:,t);         % value from previous step
            UpdateStateStep(esn)    % x(t) = ...
            X(:,t) = [b; esn.u; esn.x];     % append activations X
            Y(:,t+1) = esn.Wout * X(:,t);   % append forecast ts
        end
        Y(:,1)=[];  % discard i.c. (keep only forecast values)

        esn.Xy = X; % replace trained activations with forecast activations
    end

    function [Y] = ForecastPushMap(esn, u, T)
    % ForecastPushMap(esn, u, T)
    % EXPERIMENTAL
    % Use the trained ESN for time-series forecasting to generate a
    % forecast Y, with initial conditions u, and length (time T)
    %   * Applicable to other sequence generation tasks.
    %   * Deals with 'sliding window' where input u = [u(t),...,u(t+k)]
    %     with target output y = u(t+k+1).
    %
    % Y = esn.ForecastPushMap(u, T)

        % initialise forecast time-series length
        Window = zeros(size(u,1),T+1); % setup window
        Window(:,1) = u;               

        outDim = esn.ioDims(2);
        b = esn.hyperparameters.biasScalar; % bias scalar
        Y = zeros(outDim,T);                % forecast

        for t = 1:T
            esn.u = Window(:,t);    % value from previous step
            UpdateStateStep(esn)    % x(t) = ...
            forecastval = esn.Wout * [ b; esn.u ; esn.x];
            Window(:,t+1) = [Window(1+outDim:end,t); forecastval];
            Y(:,t) = forecastval;
        end

    end

    function Train(esn, U, Y, washout)
    % Train(esn, U, Y, washout)
    % Default ESN training - everything at once (1 batch)
    % Set washout=0; to train the ESN without washout
    %
    % esn.Train(U, Y, washout)

        % 1.0 washout
        washU = U(:,1:washout);       % washout length (0=none)
        Washout(esn, washU, washout); % perform washout
        % post-washout training sets
        trainU = U(:,washout+1:end);  % post-washout input training set
        trainY = Y(:,washout+1:end);  % post-washout output training set
        
        % 2.0 run the ESN to get X
        %   2.1 generate echoes (activations) time-series X and compute
        %   matXX=XX' and matYX=YX'
        EchoesTrainingStep(esn, trainU, trainY) % 1-batch

        % 3.0 Compute OutputWeights
        SolveOutputWeights(esn)
    end 
    
    function TrainBatch(esn, U, Y, washout, numBatches)
    % TrainBatch(esn, U, Y, washout, numBatches)
    % ESN training in batches to avoid dealing with large activation X ts
    % washout=0;    to remove washout
    % numBatches=1; do everything in 1 batch (defaut ESN.Train)
    %
    % esn.TrainBatch(U, Y, washout, numBatches)
        % 1.0 washout
        washU = U(:,1:washout);       % washout length (0=none)
        Washout(esn, washU, washout); % perform washout

        % post-washout training sets
        trainU = U(:,washout+1:end);  % post-washout input training set
        trainY = Y(:,washout+1:end);  % post-washout output training set

        T = size(trainU,2);               % training data length
        batchLength = ceil(T/numBatches); % length of a single batch

        % 2.0 run the ESN to get X
        %   2.1 generate 'echoes' (activation) time-series X and
        %   compute/append matXX=XX'; and matYX=YX';
        % NOTE: fprintf() statements can be commented out to speed up
        % performance (alternative to waitbar)

        % if there is only 1 batch - default training
        if numBatches==1
            % one batch - everything is done in 1 step
            EchoesTrainingStep(esn, trainU, trainY);
            % fprintf('\tTrained in single Batch of length %d\n',T)
        else
            % Train for all but final batch
            for s = 1:numBatches-1
                s0 = 1+(s-1)*batchLength;   % lower index (batch start)
                s1 = s*batchLength;         % upper index (batch end)
                EchoesTrainingStep(esn, trainU(:,s0:s1), trainY(:,s0:s1))
                % fprintf('\tTraining Batch\t[%d/%d]\tRange(%d,%d)\n',s,numBatches,s0,s1)
            end
            % Train final batch:
            % Can be larger (e.g. 10/3 splits into [1:3, 4:6, 7:10])
            EchoesTrainingStep(esn, trainU(:,s1+1:end), trainY(:,s1+1:end))
            % fprintf('\tTraining Batch\t[%d/%d]\tRange(%d,%d)\n',s,numBatches,s1,T)
        end

        % 3.0 Compute Output Weights
        SolveOutputWeights(esn)
    end

    function EchoesTrainingStep(esn, U, Y)
    % EchoesTrainingStep(esn, U, Y)
    % ESN training - generate activation matrix X and update matrices
    % matXX=X*X'; matYX=Y*X'; which are used in solvers/our research
    % Generate activations matrix X and then use it to update matrices
    %
    % esn.EchoesTrainingStep(U, Y)
        Echoes(esn, U);                 % Generate activations tsX
        UpdateTrainingParams(esn, Y);   % Update matXX=XX', matYX=YX'
    end

    function SolveOutputWeights(esn)
    % SolveOutputWeights(esn)
    % Solve for output weights Wout, uses ESNFunctions class
    % Update internal esn.Wout
    % Currently only ridge-regression solver is available
    % 
    % esn.SolveOutputWeights
        switch esn.solverType
            case {'default', 'ridge'}
                ESNFunctions.RidgeRegressionSolver(esn);
            case {'ed'}
                ESNFunctions.EDSolver(esn);
        end
    end

end

methods (Hidden=true)
    
    function UpdateStateStep(esn)
    % UpdateStateStep(esn)
    % Update reservoir states x(t) = Func( x(t-1), u(t), ... ) 
    % Update internal esn.x, e.g.
    % x(t) = (1-alpha)*x(t-1) + ...
    %             alpha*ACTIVATION( Win*u(t)+W*x(t-1)+... )
    %
    % esn.UpdateStateStep

        leakingRate = esn.hyperparameters.leakingRate;
        esn.x = (1-leakingRate) * esn.x + ...
                 leakingRate * esn.Activate( esn );
    end

end


properties (Access=public, Constant=true)
    esnVersion = 'release-1.1';   % version
end

end