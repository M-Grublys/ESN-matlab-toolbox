function [] = PlotRMSE(testTimeVar, testY, Y, zoomTime, rmseThresh, PlotParams)
% PlotRMSE
%   testTimeVar = x-axis (time/iteration)
%   testY = true data
%   Y = forecast
%   zoomTime = x-limits
%   rmseThresh = threshold line plot
%   PlotParams = plot params struct

    % Compute rmse 
    [rmseSeries, ~, ~] = ...
        ESNPerformanceSeries(testY, Y);
    
    figure('Name','RMSE')

    % Entire series
    subplot(2,1,1); hold on;
    p11 = plot(testTimeVar, rmseThresh.*ones(size(rmseSeries)),...
        'Color','black', 'LineStyle','--', 'LineWidth',2);
    p12 = plot(testTimeVar, rmseSeries,...
        'Color','red', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    ylim([0 1.1*max(rmseSeries)]);
    axisLimits = [min(testTimeVar), max(testTimeVar)];
    PlotParamControl(gca, axisLimits, PlotParams);   
    
    xlabel('Time','Interpreter','latex');
    ylabel('RMSE','Interpreter','latex');
    legend([p11, p12],'Error Threshold','RMSE')
    legend(gca,'Interpreter','latex');
    set(gca,'YScale','log')

    % to errTime
    subplot(2,1,2); hold on;  
    p21 = plot(testTimeVar(1:zoomTime), rmseThresh.*ones(1,zoomTime),...
        'Color', 'black', 'LineStyle', '--',...
        'LineWidth',2);
    p22 = plot(testTimeVar(1:zoomTime), rmseSeries(1:zoomTime),...
        'Color','red', 'LineStyle','-',...
        'LineWidth',PlotParams.LineWidth);
    ylim([0 1.1*max(rmseSeries(1:zoomTime))])
    axisLimits = [min(testTimeVar(1:zoomTime)), max(testTimeVar(1:zoomTime))];
    PlotParamControl(gca, axisLimits, PlotParams)    

    xlabel('Time','Interpreter','latex');
    ylabel('RMSE','Interpreter','latex');
    legend([p21, p22],'Error Threshold','RMSE')
    legend(gca,'Interpreter','latex');
    set(gca,'YScale','log')
end