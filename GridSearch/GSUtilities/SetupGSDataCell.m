function [dataCell] = SetupGSDataCell(hyperparamGrid)
%SetupGSDataCell
%   Create a cell to hold gridsearch results
%       {i1}{i2}{i3}{i4} = result 
%   Get the size of gridsearch hyperparameters
%       I1: # reservoir sizes
%       I2: # win scalars
%       I3: # spectral radii
%       I4: # leaking rates

%
I1 = length(hyperparamGrid.reservoirSizeVect);
I2 = length(hyperparamGrid.winScalarVect);
I3 = length(hyperparamGrid.spectralRadiusVect);
I4 = length(hyperparamGrid.leakingRateVect);

dataCell = { cell(1, I1) }; % for each reservoirSize
for i1=1:I1
    dataCell{i1} = cell(1,I2);  % for each winScalar
    for i2=1:I2
        dataCell{i1}{i2} = cell(1,I3);  % for each spectralRadius
        for i3=1:I3
            dataCell{i1}{i2}{i3} = cell(1,I4);  % for each leakingRate
            for i4=1:I4
                dataCell{i1}{i2}{i3}{i4} = [];  % data vector (in final cell nest)
            end
        end
    end
end
                