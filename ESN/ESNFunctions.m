classdef ESNFunctions
% ESNFunctions
% ESN Solvers
%   RidgeRegressionSolver - default
%   EDSolver - Eigenvalue Decomposition
%
% Other functions (used for activations in ESNSetup)
%   selu
%   binarystep
%   softmax

properties
end
    
methods (Static)
    function RidgeRegressionSolver(esn)
    % RIDGEREGRESSIONSOLVER
    % Solve (train) ESN using ridge regression
        rrCoeff = esn.hyperparameters.rrCoeff;
        % size (#rows) of matXX
        Nr = esn.hyperparameters.reservoirSize + ...
             esn.ioDims(1) + esn.hyperparameters.hasBias;
        % Ridge Regression
        esn.Wout = ( (esn.matXX + rrCoeff*eye(Nr)) \...
                     (esn.matYX') )';
    end

    function EDSolver(esn)
    % EDSSOLVER
    % Solve (train) ESN using ED of XX' instead of XX' (slow)
        rrCoeff = esn.hyperparameters.rrCoeff;
        Nr = esn.hyperparameters.reservoirSize + ...
             esn.ioDims(1) + esn.hyperparameters.hasBias;

        [V, D] = eig(esn.matXX+rrCoeff*eye(Nr));

        esn.Wout = (esn.matYX*V) * (D)^-1 * V';
        %esn.Wout = (esn.matYX*V) * (D+rrCoeff*eye(Nr))^-1 * V';
    end

    function z = selu(z)
        % param source: https://en.wikipedia.org/wiki/Activation_function
        lambda=1.0507;
        alpha=1.67326;
        z0 = find(z<0);
        z1 = find(z>=0);
        z(z0) = lambda*alpha*(exp(z(z0))-1);
        z(z1) = lambda*z(z1);
    end

    function z = binarystep(z)
        z(z>=0) = 1;    % order is important  as z(0)=1
        z(z<0) = 0;
    end

    function z = softmax(z)
        z = exp(z) ./ sum(exp(z));
    end

end
    
end