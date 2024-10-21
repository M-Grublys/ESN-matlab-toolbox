classdef ESNHyperparameters
% ESNHyperparameters 
% Stores all ESN hyperparameters

properties (GetAccess=public, SetAccess=public)
    
    % Input Weights
    winScalar = 1;
    winrngDist = 'uniform';
    
    % Reservoir
    reservoirSize = 1e2;
    spectralRadius = 0.95;
    resrngDist = 'uniform';
    isSparse = true;
    sparsity = 0.05;
    
% Bias
    hasBias = true;
    biasScalar = 1;
    fixBiasScalar = true;   % fix to match winScalar
    
    % Feedback Weights | wip
    hasFeedback = false;
    fbScalar = 1;
    fixfbScalar = true;     % fix to match winScalar
    
    % Training
    leakingRate = 0.5;
    % Activation Function
    activation = 'tanh';
        
    % Ridge-Regression Solver | default
    rrCoeff = 1e-8;
     
end

properties (Hidden)
    % Reservoir generation control
    % attempt to generate reservoir with initial 1e-10<rho<1e3 to avoid
    % some numerical issues. Limits can be changed, especially maxRho when
    % working with large reservoirs. Irrelevant when using 1/sqrt(N)
    % scaling
    maxWrGenAttempts = 30;
    minRho = 1e-10;
    maxRho = 1e3;
end

methods
    
    function hyperparams = ESNHyperparameters(varargin)
    % ESNHyperparameters
    % Initialise ESNs hyperparameters
    
        p = inputParser;
        
        % Input Weights
        addOptional(p,'winScalar', hyperparams.winScalar);
        addOptional(p,'winrngDist', hyperparams.winrngDist);
        % Reservoir Parameters
        addOptional(p,'resrngDist', hyperparams.resrngDist);
        addOptional(p,'reservoirSize', hyperparams.reservoirSize);
        addOptional(p,'spectralRadius', hyperparams.spectralRadius);
        addOptional(p,'isSparse', hyperparams.isSparse);
        addOptional(p,'sparsity', hyperparams.sparsity);
        % Bias
        addOptional(p,'hasBias', hyperparams.hasBias);
        addOptional(p,'biasScalar', hyperparams.biasScalar);
        addOptional(p,'fixBiasScalar',hyperparams.fixBiasScalar);
        % Feedback - Optional
        addOptional(p,'hasFeedback', hyperparams.hasFeedback);
        addOptional(p,'fbScalar', hyperparams.fbScalar);
        addOptional(p,'fixfbScalar', hyperparams.fixfbScalar);
        % Training - Base
        addOptional(p,'leakingRate', hyperparams.leakingRate);
        addOptional(p,'activation', hyperparams.activation);
        % Training - Optional       
        addOptional(p,'rrCoeff', hyperparams.rrCoeff);
        
        parse(p,varargin{:});
        
        % Input Weights
        hyperparams.winScalar = p.Results.winScalar;
        hyperparams.winrngDist = p.Results.winrngDist;
        % Reservoir Parameters
        hyperparams.resrngDist = p.Results.resrngDist;
        hyperparams.reservoirSize = p.Results.reservoirSize;
        hyperparams.spectralRadius = p.Results.spectralRadius;
        hyperparams.isSparse = p.Results.isSparse;
        hyperparams.sparsity = p.Results.sparsity;
        % Bias
        hyperparams.hasBias = p.Results.hasBias;
        hyperparams.biasScalar = p.Results.biasScalar;
        hyperparams.fixBiasScalar = p.Results.fixBiasScalar;
        % Feedback - Optional
        hyperparams.hasFeedback = p.Results.hasFeedback;
        hyperparams.fbScalar = p.Results.fbScalar;
        hyperparams.fixfbScalar = p.Results.fixfbScalar;
        % Training - Base
        hyperparams.leakingRate = p.Results.leakingRate;
        hyperparams.activation = p.Results.activation;
        % Training - Optional
        hyperparams.rrCoeff = p.Results.rrCoeff;
         
        % Deal with "fixed" parameters
        if hyperparams.fixBiasScalar && hyperparams.hasBias
            hyperparams.biasScalar = hyperparams.winScalar(1);
        end
        if hyperparams.fixfbScalar && hyperparams.hasFeedback
            hyperparams.fbScalar = hyperparams.winScalar(1);
        end
        
    end
end

end