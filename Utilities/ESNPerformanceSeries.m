function [rmseSeries, intensitySeries, relerrSeries] = ...
	ESNPerformanceSeries(testY, Y)
% ESNPerformanceSeries()
%   Evaluate ESNs performance via rmse and (intensity-based) relative
%   error ('percentage error')
%   Outputs relevant time-series for the rmse, intensity, and relative
%   error
%   intensity = dot( testY, testY, 1)
    
    T = size(Y,2);

    e = dot( (testY-Y),(testY-Y), 1);   % for rmse
    intensity = dot( testY, testY, 1);  % for percentage
    
    rmseSeries = zeros(1,T);       % store rmse series
    intensitySeries = zeros(1,T);  % store intensity series
    relerrSeries = zeros(1,T);     % store relerr series
    
    for t = 1:T
        rmseSeries(t) = sqrt( mean(e(1:t)) );
        intensitySeries(t) = sum( intensity(1:t) )./t;
        relerrSeries(t) = rmseSeries(t) ./ sqrt( intensitySeries(t) );
    end

end