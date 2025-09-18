function [] = PlotComparison3D(testY, Y, PlotParams)
% PlotComparison3D
%   testY = true data (3D)
%   Y = forecast data (3D)
%   PlotParams struct
%
%   3 subplots: true data, forecast, and combined

    limitsXAxis = [min([testY(1,:),testY(1,:)]),...
                   max([testY(1,:),testY(1,:)])];
    limitsYAxis = [min([testY(2,:),testY(2,:)]),...
                   max([testY(2,:),testY(2,:)])];
	limitsZAxis = [min([testY(3,:),testY(3,:)]),...
                   max([testY(3,:),testY(3,:)])];

    axisLimits = [limitsXAxis; limitsYAxis; limitsZAxis];
               
    figure('Name','Forecast');

    subplot(1,3,1)
    p11 = plot3(testY(1,:), testY(2,:), testY(3,:),...
          'Color','blue', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)
    
    xlabel('Data $U_1$','Interpreter','latex');
    ylabel('Data $U_2$ ','Interpreter','latex');
    zlabel('Data $U_3$ ','Interpreter','latex');
    legend(p11,'Test Data');
    legend(gca,'Interpreter','latex');
    
    subplot(1,3,2)
    p21 = plot3(Y(1,:), Y(2,:), Y(3,:),...
          'Color','red', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)
    
    xlabel('Data $U_1$','Interpreter','latex');
    ylabel('Data $U_2$ ','Interpreter','latex');
    zlabel('Data $U_3$ ','Interpreter','latex');
    legend(p21,'Forecast');
    legend(gca,'Interpreter','latex');
    
    subplot(1,3,3); hold on;
    p31 = plot3(testY(1,:), testY(2,:), testY(3,:),...
        'Color','blue', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    p32 = plot3(Y(1,:), Y(2,:), Y(3,:),...
        'Color','red', 'LineStyle','--', 'LineWidth',PlotParams.LineWidth);
	PlotParamControl(gca, axisLimits, PlotParams)
    
    xlabel('Data $U_1$','Interpreter','latex');
    ylabel('Data $U_2$ ','Interpreter','latex');
    zlabel('Data $U_3$ ','Interpreter','latex');
    legend([p31,p32],'Test Data','Forecast');
    legend(gca,'Interpreter','latex');
    
end