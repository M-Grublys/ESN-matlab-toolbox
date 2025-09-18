function [] = PlotDifference(testTimeVar, testY, Y, zoomTime, PlotParams)
% PlotDifference
%   testTimeVar = x-axis (time/iteration)
%   testY = true data
%   Y = forecast
%   zoomTime = x-axis limits
%   PlotParams = plot params struct
%
%   plot difference:    diff = testY - Y
%   note that this is 1D subtraction, not distance

    figure('Name','Difference');

    subplot(2,1,1); hold on;
    plot(testTimeVar, zeros(1,size(Y,2)),...
        'Color','black', 'LineStyle','-', 'LineWidth',2);
    p11 = plot(testTimeVar, testY(1,:) - Y(1,:),...
        'Color','red', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    axisLimits = [min(testTimeVar), max(testTimeVar)];
    PlotParamControl(gca, axisLimits, PlotParams)  
    
    xlabel('Time','Interpreter','latex');
    ylabel('Difference','Interpreter','latex');
    legend(p11,'Difference');
    legend(gca,'Interpreter','latex');
    
    subplot(2,1,2); hold on;    
    plot(testTimeVar(1,1:zoomTime), zeros(1,zoomTime),...
        'Color','black', 'LineStyle','-', 'LineWidth',2);
    p21 = plot(testTimeVar(1,1:zoomTime), testY(1,1:zoomTime) - Y(1,1:zoomTime),...
        'Color','red', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    axisLimits = [min(testTimeVar(1:zoomTime)), max(testTimeVar(1:zoomTime))];
    PlotParamControl(gca, axisLimits, PlotParams)  

    xlabel('Time','Interpreter','latex');
    ylabel('Difference','Interpreter','latex');
    legend(p21,'Difference');
    legend(gca,'Interpreter','latex');
    