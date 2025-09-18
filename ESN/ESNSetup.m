classdef ESNSetup
% ESNSetup class
% Initialises parts of the ESN class
    
properties
    % n/a at this time
end

methods (Static)

	function InputWeights(esn)
    % InputWeights(esn)
    % Generate the input weights and bias vector
    % Bias is optional, but set to true by default
    % RNG options: uniform U(-1,1) or normal N(0,1) 

        winrngDist = esn.hyperparameters.winrngDist; % rng
        winScalar = esn.hyperparameters.winScalar;   % scalar
        
        reservoirSize = esn.hyperparameters.reservoirSize;
        
        hasBias = esn.hyperparameters.hasBias;       % bias bool
        biasScalar = esn.hyperparameters.biasScalar; % scalar

        inDim = esn.ioDims(1); % input dim
        
        switch lower(winrngDist)
            case {'uniform', 'rand'}    % U (-1,1)
                esn.Win = ...
                    (2*rand(reservoirSize, inDim+hasBias)-1);
            case {'normal', 'randn'}    % N (0,1)
                esn.Win = ...
                    randn(reservoirSize, inDim+hasBias);
            otherwise
                error('Error: bad <strong>rng</strong>')
        end
        
        if hasBias
            esn.B = biasScalar .* esn.Win(:,1);      % scale bias
            esn.Win = winScalar .* esn.Win(:,2:end); % scale Win
        else
            esn.Win = winScalar .* esn.Win; % scale Win (no bias)
        end
        
    end

    function Reservoir(esn)
    % Reservoir(esn)
    % Generate the reservoir Wr of the ESN
    % RNG options:  Uniform U(-1,1) or Normal N(0,1)
        
        % generation settings
        maxWrGenAttempts = esn.hyperparameters.maxWrGenAttempts; % # attempts
        minRho = esn.hyperparameters.minRho;  % (lower numeric err/limit)
        maxRho = esn.hyperparameters.maxRho;  % (upper numeric err/limit)
        attempt = 0; % counter
        rhoWr = 1;   % spectral radius placeholder 

        reservoirSize = esn.hyperparameters.reservoirSize;   % size
        spectralRadius = esn.hyperparameters.spectralRadius; % spectral radius hp
        
        isSparse = esn.hyperparameters.isSparse; % sparsity bool
        sparsity = esn.hyperparameters.sparsity; % sparsity %(0,1)
        
        resrngDist = esn.hyperparameters.resrngDist; % rng: Uniform/Normal
        
        % reservoir generation loop
        while attempt < maxWrGenAttempts
            % switch based on chosen RNG distribution
            switch lower(resrngDist)
                case {'uniform', 'rand'}    % U (-1,1)
                    if isSparse
                        esn.Wr = sprand(reservoirSize, reservoirSize, sparsity);
                        esn.Wr(esn.Wr~=0) = 2*esn.Wr(esn.Wr~=0)-1;       % change range (-1,1)
                    else
                        esn.Wr = 2*rand(reservoirSize, reservoirSize)-1; % change range (-1,1)
                    end
                case {'normal', 'randn'}    % N (0,1)
                    if isSparse
                        esn.Wr = randn(reservoirSize, reservoirSize, sparsity);
                    else
                        esn.Wr = randn(reservoirSize, reservoirSize);
                    end
                otherwise
                    error('Error: bad <strong>rng</strong>')
            end
            
            % get spectral radius of the 'current' matrix
            rhoWr = abs(eigs(esn.Wr, 1, 'largestabs')); % SLOW WHEN LARGE

            % rescalse the spectral radius, or try again (new reservoir)
            % minRho/maxRho are hidden params from ESNHyperparameters
            if (abs(rhoWr)>minRho) && ~isnan(rhoWr) && (rhoWr<maxRho)
                esn.Wr = (spectralRadius/rhoWr) * esn.Wr;
                break;
            else
                attempt = attempt + 1;
                if (attempt>maxWrGenAttempts)
                    % technically we could keep a 'bad' reservoir, or
                    % simply use a different rescale method, say 1/sqrt(N)              
                    error('Error: failed to generate a good reservoir')
                end
            end
        end
        
    end
    
    function FeedbackWeights(esn)
    % FeedbackWeights(esn)
    % Generate feedback weights for the ESN
    % Work In Progress -> errorr
        error('FeedbackWeights() WIP')
    end
    
    function InitTrainingParams(esn)
    % InitTrainingParams(esn)
    % Initialise training parameters used in ridge-regression:
    %   matXX = XX'     size(N,N)
    %   matYX = YX'     size(outDim,N)

        inDim = esn.ioDims(1);  % inputs dim
        outDim = esn.ioDims(2); % outputs dim
        reservoirSize = esn.hyperparameters.reservoirSize;   % size
        N = inDim + reservoirSize + esn.hyperparameters.hasBias;

        esn.matXX = zeros(N,N);
        esn.matYX = zeros(outDim,N);
    end

    function SetActivation(esn)
    % SetActivation(esn)
    % Set the activation function for the ESN, 'tanh' by default
    % All Available Activations:
    %   tanh / sigmoid / relu / leakyrelu / gaussian / softplus
    %   binarystep / silu / id / selu/ gelu / softmax / none
    %
    % List (10/2024): https://en.wikipedia.org/wiki/Activation_function

        funcString = ''; % dummy func name string
        zString = '';    % dummy for inside operations
        
        % NOTE: assume that bias exists. Should work if B = []
        if ~esn.hyperparameters.hasFeedback
            zString = 'esn.Win * esn.u + esn.Wr*esn.x + esn.B';
        else
            zString = 'esn.Win * esn.u + esn.Wr * esn.x + esn.B + esn.Wfb * esn.y';
        end
        
        % set the activation function
        switch lower(esn.hyperparameters.activation)
            case 'tanh'
                funcString = ['tanh(', zString, ')'];
            case 'sigmoid'
                funcString = ['(1 + exp(-(', zString, '))).^-1'];
            case 'relu'
                funcString = ['max(', zString, ', 0)'];
            case 'leakyrelu'
                funcString = ['max(' zString, ', 0.01*(', zString, '))'];
            case 'gaussian'
                funcString = ['exp(-(',zString,').^2)'];
            case 'softplus'
                funcString = ['log(1 + exp(',zString,'))'];
            case 'binarystep'
                funcString = ['ESNFunctions.binarystep(',zString,')'];
            case 'silu' % (sigmoid linear unit)
                funcString = [zString,'.* (1 + exp(-(', zString, '))).^-1'];
            case 'id'
                funcString = zString;
            case 'selu' % scaled exponential linear unit
                funcString = ['ESNFunctions.selu(',zString,')'];
            case 'gelu' % gaussian error linear unit
                funcString = ['0.5*(',zString,').*(1+erf(',zString,'./sqrt(2)))'];
            case 'softmax'
                funcString = ['ESNFunctions.softmax(',zString,')'];
            case {'linear','none'} % linear/none (no activation)
                funcString = zString;
            otherwise
                erstr = ['\tBAD ACTIVATION NAME:\n',...
                         '\ttanh/sigmoid/relu/leakyrelu/gaussian/softplus',...
                         '\n\tbinarystep/silu/id/selu/gelu/softmax\n'];
                error(sprintf(erstr))
        end

        esn.Activate = str2func(['@(esn) ', funcString]);   

    end
   
    function SetCurrentState(esn, initState)
    % SetCurrentState(esn, initState)
    % Set reservoir state x(t) to
    %   1) [x1,...,xn]    vector of same size, e.g. "ones(N,1)"
    %   2) "rand"         random from uniform U (-1,1)
    %   3) "randn"        random from normal N (0,1)
    %   4) "zeros"        vector off zeros "zeros(N,1)"
    % initialised as "zeros" by default
        N = esn.hyperparameters.reservoirSize;

        if isnumeric(initState)
            if size(initState)==[N,1]
                esn.x = initState;
            else
                fprintf('Bad Input (size): x(0) set to zeros')
                esn.x = zeros(N,1);
            end
            return;
        end

        switch lower(initState)
            case 'rand'     % U (-1,1)
                esn.x = 2*rand(N,1)-1;
            case 'randn'    % N (0,1)
                esn.x = randn(N,1);
            case 'zeros'
                esn.x = zeros(N,1);
            otherwise
                fprintf('Bad Input (string): x(0) set to zeros\n')
                fprintf('Use "rand", "randn", "zeros"\n')
                esn.x = zeros(N,1);
        end
    end

end
    
end