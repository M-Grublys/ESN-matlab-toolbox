function [H, powerVal] = get_PowerHistogram(data, rangeType, rangeVals, varargin)
% get_PowerHistogram(data, rangeType, rangeVals)
%   [powerVal] = getPowerHistogram(data, rangeType, rangeVals)
%   Assume that data follows some power law in range defined by rangeVals.
%   Returns the approximated powerVal for data in powerLawRange using
%   getPowerLaw() function.
%   Outputs the histogram object H and approximated power powerVal.
%
%   optional inputs:
%       numBins (default 50) = # histogram bins
%       keepFit (default true) = produce histogram (H=[] if false)

numBins = 50;
if nargin>=4; numBins=varargin{1}; end
if (numBins>length(data)); numBins=ceil(length(data)/2); end

keepFig = true;
if nargin>=5; keepFig=varargin{2}; end

fig = figure; hold on;

[~,edges] = histcounts(log10(data),numBins);
H = histogram(data,10.^edges,'Normalization','pdf',...
              'FaceColor',[45,90,145]./255); 

% power law estimated by algorithm
powerVal = get_PowerLaw(data,rangeType,rangeVals);
% there is no need to plot if we are not saving the figure
if ~keepFig; close(fig); H=[]; return; end


% plot power-law estimate
xPowerPlot = 10.^edges([3,end-2]);
yPowerPlot = 1 ./ xPowerPlot.^powerVal;

plot(xPowerPlot, yPowerPlot, '-.r','LineWidth',5);

% old: plot "power law" fit
% plot(10.^edges([3,end-2]),1./(10.^edges([3,end-2])).^powerVal,...
%     '-.r','LineWidth',3);
% set(gca, 'xscale','log','yscale','log')

xlabel('$\lambda$','Interpreter','latex','FontSize',20);
set(gca,'xscale','log','yscale','log');

legend({'',['$p_{alg} \approx$ ',sprintf('%.3f',powerVal)]},...
        'Interpreter','latex','FontSize',20);

xlim(H.BinLimits)
ylim([min(H.Values(H.Values>0))*1e-3, max(H.Values)])
