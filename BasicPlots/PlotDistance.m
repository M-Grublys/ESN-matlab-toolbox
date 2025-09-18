function [] = PlotDistance(testTimeVar, testY, Y, zoomTime, PlotParams)
% PlotDistance
%   testTimeVar = x-axis (time/iteration)
%   testY = true data
%   Y = forecast
%   zoomTime = x-limits
%   PlotParams = plot params struct
%
%   distance between testY and Y trajectories
%   absDist = sqrt( dot((testY-Y),(testY-Y),1) )

    figure('Name','Distance');

    absDist = sqrt( dot( (testY-Y),(testY-Y), 1) );
    
    subplot(2,1,1); hold on;
    plot(testTimeVar, zeros(1,size(Y,2)),...
        'Color','black', 'LineStyle','-', 'LineWidth',2);
    p11 = plot(testTimeVar, absDist,...
        'Color','red', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    axisLimits = [min(testTimeVar), max(testTimeVar)];
    PlotParamControl(gca, axisLimits, PlotParams)  
    
    xlabel('Time','Interpreter','latex');
    ylabel('Distance','Interpreter','latex');
    legend(p11,'Distance');
    legend(gca,'Interpreter','latex');
    
    subplot(2,1,2); hold on;
    plot(testTimeVar(1,1:zoomTime), zeros(1,zoomTime),...
        'Color','black', 'LineStyle','-', 'LineWidth',2);
    p21 = plot(testTimeVar(1,1:zoomTime), absDist(1,1:zoomTime),...
        'Color','red', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    axisLimits = [min(testTimeVar(1:zoomTime)), max(testTimeVar(1:zoomTime))];
    PlotParamControl(gca, axisLimits, PlotParams)
    
    xlabel('Time','Interpreter','latex');
    ylabel('Distance','Interpreter','latex');
    legend(p21,'Distance');
    legend(gca,'Interpreter','latex');