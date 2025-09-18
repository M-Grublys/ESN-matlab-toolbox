function [H, powerFit] = get_PowerHistLOBF(data, numBins, lobfBinPoints, varargin)
% get_PowerHistLOBF
% attempt to find the power law exponent using "log-log lobf" method. in
% this case we draw a line between the midpoints of bins (specified in
% inputs) and use polyfit to estimate the gradient (power law) & constant
%
% INPUTS
% numBins = # bins for histogram
% lobfBinPoints = 2 points for lobf by bin index (left, right)
%   e.g. numBins = 15;
%        lobfBinPoints = [2, 3];   % same as bins (2, end-3) = (2, 12)
% optional varargin{1} = keepFig
%   true/false to keep the figure; if false then H is empty
%
% OUTPUTS
% H = histogram object (NOT THE FIGURE!)
% powerFit = [p, c] such that y ~ exp(c) * x^p

keepFig = true; % keepFig is optional (varargin{1})
if nargin>3; keepFig=varargin{1}; end

i0 = lobfBinPoints(1);  % left bin point
i1 = lobfBinPoints(2);  % right bin point

[~, edges] = histcounts(log10(data),numBins);

fig=figure; hold on;
H = histogram(data,10.^edges,'Normalization','pdf',...
              'FaceColor',[45,90,145]./255,'HandleVisibility','off'); 

    x_points = H.BinEdges; y_points = H.Values;
    x_points = (x_points(2:end)-x_points(1:end-1))/2; % bin mid-points

    x12 = [x_points(i0), x_points(end-i1)]; % min/max x point
    y12 = [y_points(i0), y_points(end-i1)]; % min/max y point
    x12_log = log(x12); y12_log = log(y12); % log-log scale

    powerFit = polyfit(x12_log, y12_log, 1); % fit line
    ma12 = powerFit(1); ca12 = powerFit(2);  % log-log const/gradient

    % there is no need to plot if we are not saving the figure
    if ~keepFig; close(fig); H=[]; return; end

    plot(x12, exp(ca12) .* x12.^ma12,'-.r','LineWidth',5,...
        'DisplayName',['$p_{lobf} \approx$ ',sprintf('%.4f',abs(ma12))])

    legend('Interpreter','latex','FontSize',20)
    set(gca,'XScale','log','YScale','log')

    xlim(H.BinLimits)
    ylim([min(H.Values(H.Values>0))*1e-3, max(H.Values)])
