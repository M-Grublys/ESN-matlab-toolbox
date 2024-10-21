function [powerVal, powerLawRange]  = get_PowerLaw(data, rangeType, rangeVals)
% get_PowerLaw(data, rangeType, rangeVals)
%   [powerVal, powerLawRange] = getPowerLaw(...).
%   Assume that data follows some power law in range defined by rangeVals.
%   Returns the approximated powerVal for data in powerLawRange. Range
%   output is a 2-vector [minIndex, maxIndex] w.r.t. to data input
%
%   data = input data vector (sorted in ascending order, must be 1D array)
%
%   rangeType & rangeVals:
%   1) Use find() to get min/max index based on min/max values
%       rangeType = {'value', 0}
%       rangeVals = [minVal, maxVal]
%   2) Choose index range manually
%       rangeType = {'index', 1}
%       rangeVals = [minIndex, maxIndex]
%
%   EXAMPLE:
%       [powerVal, ~] = get_PowerLaw([1:100:1001].^-1.5, 'value', [1e-9, 1])
%       figure; hold on;
%       plot([1:100:1001],[1:100:1001].^(-1.5),'-b')
%       plot([1,1001],[1,1001].^(-powerVal),'--r')
%       set(gca,'XScale','log','YScale','log')

data = sort(data,'ascend'); % precaution (data is usually already sorted)

switch lower(rangeType) % auto-ignored for numeric/bool inputs
    case {'value',0}  
        % smallest value
        minVal = rangeVals(1);	% e.g. 5e-9
        minIndex = find(data>=minVal,1,'first');
        minVal = data(minIndex);    % true value used in algorithm
        % largest value
        maxVal = rangeVals(2);   % e.g. 1e4
        maxIndex = find(data<=maxVal,1,'last');
    case {'index',1}
        % smallest value
        minIndex = rangeVals(1);    % e.g. 150
        minVal = data(minIndex);
        % largest value
        maxIndex = rangeVals(2);    % e.g. length(data)-3
        maxVal = data(maxIndex);    % [not needed]
    otherwise
        error('Bad rangeType: type ''help'' for more information')
end

powerLawRange = [minIndex, maxIndex];   % data range

N = maxIndex - minIndex + 1;   % # values in range

powerSumVal = 0;
% power law approximation algorithm, ref:
% doi: 10.1137/070710111.
for i = minIndex:maxIndex
    powerSumVal = powerSumVal + log( data(i)/minVal );
end

powerVal = 1 + N*powerSumVal.^(-1); % approximate power law