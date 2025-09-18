function [] = PlotComparison1D(testTimeVar, testY, Y, PlotParams)
% PlotComparison1D
%   testTimeVar = x-axis (time/iteration)
%   testY = true data
%   Y = forecast data
%   PlotParams struct
%
%   3 subplots: true data, forecast, and combined

    limitsXAxis = [min(testTimeVar),...
                   max(testTimeVar)];

    axisLimits = limitsXAxis;
               
    figure('Name','Forecast');
    
    subplot(1,3,1)
    p11 = plot(testTimeVar, testY(1,:),...
        'Color','blue', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)

    xlabel('Time','Interpreter','latex');
    ylabel('Data $U_1$','Interpreter','latex');
    legend(p11,'Data');
    legend(gca,'Interpreter','latex');
    
    subplot(1,3,2)
    p21 = plot(testTimeVar, Y(1,:),...
        'Color','red', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)

    xlabel('Time','Interpreter','latex');
    ylabel('Data $U_1$','Interpreter','latex');
    legend(p21,'Forecast');
    legend(gca,'Interpreter','latex');
    
    subplot(1,3,3); hold on;
    p31 = plot(testTimeVar, testY(1,:),...
         'Color', 'blue', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    p32 = plot(testTimeVar, Y(1,:),...
        'Color','red', 'LineStyle','--', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)

    xlabel('Time','Interpreter','latex');
    ylabel('Data $U_1$','Interpreter','latex');
    legend([p31, p32],'Test Data', 'Forecast');
    legend(gca,'Interpreter','latex');
    
end