function [] = PlotEchoes(trainTimeVar, X, timeRange, rowRange, PlotParams, varargin)
% PlotEchoes
%   trainTimeVar = x-axis ("training time" plot); if empty then 1:T
%   X = activation time-series (full)
%   timeRange = timeRange (time interval to plot X)
%   rowRange = which activations to plot (1+ioDims(1)) are bias+signal
%
%   optional
%   yLimits = [minVal, maxY]; for other activation functions

    if nargin>5
        yLimits = varargin{1};
    end

    if isempty(timeRange)
        timeRange = [1:size(X,2)];
    end


    figure('Name','Activations')
    plot(trainTimeVar(timeRange), X(rowRange,timeRange)',...
        'Color','black', 'LineStyle','-', 'LineWidth',1);

    axisLimits = [min(trainTimeVar(timeRange)),...
                  max(trainTimeVar(timeRange))];
    PlotParamControl(gca, axisLimits, PlotParams)  
    
    if exist('yLimits','var'); ylim(yLimits); end
    xlabel('Time','Interpreter','latex');
    ylabel('x','Interpreter','latex');
    
    
end
    