function [H] = get_EvalHistogram(evals) 
% get_EvalHistogram(evals)
% log-log histogram of XX' eigenvalues

figure('Name','Histogram: of Eigenvalues of XX'''); hold on;

[~,edges] = histcounts(log10(evals),15);
H = histogram(evals,10.^edges,'Normalization','pdf',...
              'FaceColor',[45,90,145]./255); 
    xlabel('Eigenvalue','Interpreter','latex','FontSize',15);
    set(gca,'xScale','log','yScale','log');
    xlim(H.BinLimits)
    ylim([min(H.Values(H.Values>0))*1e-3, max(H.Values)])