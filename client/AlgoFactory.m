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
            numberDimensions = initialPrameters.length();
            startPoint = zeros(numberDimensions, 1);
            lowerBound = zeros(numberDimensions, 1);
            upperBound = zeros(numberDimensions, 1);
            for i = 1 : initialPrameters.length()
                parameter = initialPrameters.getJSONObject(i - 1);
                name = parameter.getString('name');
                index = str2double(regexp(char(name), '\d+', 'match'));
                lowerBound(index) = parameter.getDouble('minValue');
                upperBound(index) = parameter.getDouble('maxValue');
                startPoint(index) = parameter.getDouble('value');
            end            
            algorithm = algorithmContructor(...
                algorithmSettings, startPoint, initialValue, lowerBound, upperBound);            
        end
    end
    
end

