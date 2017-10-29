classdef AlgoFactory < handle
    %ALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        function algorithm = createAlgorithm(...
                algorithmConfig, initialPrameters, initialValue)
            algorithmClassName = algorithmConfig.getString('className');
            algorithmContructor = str2func(char(algorithmClassName));
            algorithmSettings = algorithmConfig.getJSONObject('settings');
            
            % parsing of starting point, initial value, lower and upper bounds
            params = JsonUtils.sortParams(initialPrameters);
            numberDimensions = params.length();
            startPoint = zeros(numberDimensions, 1);
            lowerBound = zeros(numberDimensions, 1);
            upperBound = zeros(numberDimensions, 1);
            for i = 1 : numberDimensions
                parameter = params.getJSONObject(i - 1);
                lowerBound(i) = parameter.getDouble('minValue');
                upperBound(i) = parameter.getDouble('maxValue');
                startPoint(i) = parameter.getDouble('value');
            end
            algorithm = algorithmContructor(...
                algorithmSettings, startPoint, initialValue, lowerBound, upperBound);
        end
    end
    
end

