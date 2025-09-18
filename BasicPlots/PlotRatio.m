function [] = PlotRatio(testTimeVar, testY, Y, zoomTime, PlotParams, ratioType)
% PlotRatio
%   testTimeVar = x-axis (time/iteration)
%   testY = true data
%   Y = forecast
%   zoomTime = x-limits
%   PlotParams = plot params struct
%   ratioType = "simple", "absolute", "distance"
%       "simple" (only 1D):   Y ./ testY
%       "absolute" (only 1D): abs( Y./testY )
%       "distance" (infdim): sqrt(dot(Y,Y))./sqrt(dot(testY,testY))
%
%   by default uses "distance" ('otherwise' case in switch)
%
%   NOTE: fails at points where testY=0 (cannot divide by 0)

    switch ratioType
        case {"simple"}   % old version - 1D ratio
            errRatio = Y(1,:)./testY(1,:);
        case {"absolute"} % old version - 1D ratio
            errRatio = Y(1,:)./testY(1,:);
            errRatio = abs(errRatio);
        otherwise % distance ratio (any dim)
            e1 = dot(Y,Y);
            e2 = dot(testY,testY);
            errRatio = sqrt(e1)./sqrt(e2);
    end
    
    figure('Name','Ratio');

    subplot(2,1,1); hold on;
    plot(testTimeVar, ones(1,size(Y,2)),...
        'Color','black', 'LineStyle','-', 'LineWidth',2);
    p11 = plot(testTimeVar, errRatio,...
        'Color','red', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    axisLimits = [min(testTimeVar), max(testTimeVar)];
    PlotParamControl(gca, axisLimits, PlotParams) 
    
    xlabel('Time','Interpreter','latex');
    ylabel('Ratio','Interpreter','latex');
    legend([p11],'Ratio',...
                 'Interpreter','latex');
    
    subplot(2,1,2); hold on;
    plot(testTimeVar(1,1:zoomTime), ones(1,zoomTime),...
        'Color','black', 'LineStyle','-', 'LineWidth',2);
    p21 = plot(testTimeVar(1,1:zoomTime), errRatio(1,1:zoomTime),...
        'Color','red', 'LineStyle','-', 'LineWidth',PlotParams.LineWidth);
    axisLimits = [min(testTimeVar(1:zoomTime)), max(testTimeVar(1:zoomTime))];
    PlotParamControl(gca, axisLimits, PlotParams)

    xlabel('Time','Interpreter','latex');
    ylabel('Ratio','Interpreter','latex');
    legend(p21,'Ratio');
    legend(gca,'Interpreter','latex');
    
end