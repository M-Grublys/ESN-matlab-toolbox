function [] = PlotComparison2D(testY, Y, PlotParams)
% PlotComparison2D
%   testY = true data (2D)
%   Y = forecast data (2D)
%   PlotParams struct
%
%   3 subplots: true data, forecast, and combined

    limitsXAxis = [min([testY(1,:),Y(1,:)]),...
                   max([testY(1,:),Y(1,:)])];
    limitsYAxis = [min([testY(2,:),Y(2,:)]),...
                   max([testY(2,:),Y(2,:)])];

    axisLimits = [limitsXAxis; limitsYAxis];
               
    figure('Name','Forecast');

    subplot(1,3,1)
    p11 = plot(testY(1,:), testY(2,:),...
         'Color','blue', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)
    
    xlabel('Data $U_1$','Interpreter','latex');
    ylabel('Data $U_2$ ','Interpreter','latex');
    legend(p11,'Test Data');
    legend(gca,'Interpreter','latex');
    
    subplot(1,3,2)
    p21 = plot(Y(1,:), Y(2,:),...
         'Color','red', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)

    xlabel('Data $U_1$','Interpreter','latex');
    ylabel('Data $U_2$ ','Interpreter','latex');
    legend(p21,'Forecast');
    legend(gca,'Interpreter','latex');
    
    subplot(1,3,3); hold on;
    p31 = plot(testY(1,:), testY(2,:),...
         'Color','blue', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    p32 = plot(Y(1,:), Y(2,:),...
        'Color','red', 'LineStyle','--', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)
    
    xlabel('Data $U_1$','Interpreter','latex');
    ylabel('Data $U_2$ ','Interpreter','latex');
    legend([p31,p32],'Test Data','Forecast');
    legend(gca,'Interpreter','latex');
    
end