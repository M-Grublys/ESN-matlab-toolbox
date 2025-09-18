function [wbar, wbar_fspec] = GridsearchWaitbar()
% GridsearchWaitbar.m
%   Initialise a waitbar for the grid-search loop
%   Supports parfor

strPt1 = '\\textbf{GRIDSEARCH}\n';
strPt2 = 'GridPoint = %6.d/%6.d\n\n';
strPt3 = 'Reservoir Size = %6.d\n';
strPt4 = 'Inputs Scalar = %2.6f\n';
strPt5 = 'Spectral Radius = %2.6f\n';
strPt6 = 'Leaking Rate = %1.6f\n';

wbar_fspec = [strPt1, strPt2, strPt3, strPt4, strPt5, strPt6];

wbar = waitbar(0);
wbarHandle = findobj(wbar,'Type','figure');
wbarHandle = get(get(wbarHandle,'currentaxes'),'title');
set(wbarHandle,'interpreter','latex')
set(wbarHandle,'HorizontalAlignment', 'left', ...
     'VerticalAlignment', 'bottom',...
     'Position',[1,1,0],...
     'FontSize', 15);

wbar.Position = wbar.Position.*[1,1,1,3.2];
wbar.Color = 'white';
wbar.Name = 'Gridsearch Waitbar';

waitbar(0, wbar, "Starting...")

end