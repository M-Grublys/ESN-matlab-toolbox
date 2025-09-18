function [] = PlotRelerr(testTimeVar, testY, Y, zoomTime, relerrThresh, PlotParams)
% PlotRelerr
%   testTimeVar = x-axis (time/iteration)
%   testY = true data
%   Y = forecast
%   zoomTime = x-limits
%   relerrThresh = threshold line plot
%   PlotParams = plot params struct

    % Compute rmse 
    [~, ~, relerrSeries] = ...
        ESNPerformanceSeries(testY, Y);
    
    figure('Name','Relerr Error')

    % Entire series
    subplot(2,1,1); hold on;
    p11 = plot(testTimeVar, relerrThresh.*ones(size(relerrSeries)),...
        'Color','black', 'LineStyle','--', 'LineWidth',2);
    p12 = plot(testTimeVar, relerrSeries,...
        'Color','red', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    ylim([0 1.1*max(relerrSeries)]);
    axisLimits = [min(testTimeVar), max(testTimeVar)];
    PlotParamControl(gca, axisLimits, PlotParams);   
    
    xlabel('Time','Interpreter','latex');
    ylabel('Relerr','Interpreter','latex');
    legend([p11, p12],'Error Threshold','Relerr')
    legend(gca,'Interpreter','latex');
    set(gca,'YScale','log')
    
    % to errTime
    subplot(2,1,2); hold on;  
    p21 = plot(testTimeVar(1:zoomTime), relerrThresh.*ones(1,zoomTime),...
        'Color', 'black', 'LineStyle', '--',...
        'LineWidth',2);
    p22 = plot(testTimeVar(1:zoomTime), relerrSeries(1:zoomTime),...
        'Color','red', 'LineStyle','-',...
        'LineWidth',PlotParams.LineWidth);
    ylim([0 1.1*max(relerrSeries(1:zoomTime))])
    axisLimits = [min(testTimeVar(1:zoomTime)), max(testTimeVar(1:zoomTime))];
    PlotParamControl(gca, axisLimits, PlotParams)    

    xlabel('Time','Interpreter','latex');
    ylabel('Relerr','Interpreter','latex');
    legend([p21, p22],'Error Threshold','Relerr')
    legend(gca,'Interpreter','latex');
    set(gca,'YScale','log')
end