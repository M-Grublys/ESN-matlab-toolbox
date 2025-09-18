function [] = PlotParamControl(fig, axisLimits, PlotParams)
% PlotParamControl
%   set figure params (grid,limits, etc)

    figDim = size(axisLimits,1);

    if PlotParams.addGrid
        grid(fig,'on')
    end
    if PlotParams.minorGrid
        grid(fig,'minor');
    end
    if PlotParams.fixXAxis
        set(fig,'xlim',axisLimits(1,:));
    end
    if (PlotParams.fixYAxis) && (figDim>1)
        set(fig,'ylim',axisLimits(2,:));
    end
    if (PlotParams.fixZAxis) && (figDim>2)
        set(fig,'zlim',axisLimits(3,:));
    end
    
end