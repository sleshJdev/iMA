classdef Algorithm < handle
    %ALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        algorithmFunction,
        algorithmSettings,
        terminated,
    end
    
    methods(Access = public)
        function self = Algorithm(algorithmConfig)
            algorithmFunctionName = algorithmConfig.getString('algorithmFunctionName');
            self.algorithmFunction = str2func(char(algorithmFunctionName));
            self.algorithmSettings = algorithmConfig.getJSONObject('settings');
        end
        function [message, optimizedVector, optimizedValue] = run(self,...
                initialPrameters, initialValue,...
                getNewOutputValue, log, isTerminated)
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
            [message, optimizedVector, optimizedValue] = self.algorithmFunction(...
                self.algorithmSettings,...
                initialValue, startPoint,...
                lowerBound, upperBound,...
                getNewOutputValue, log, isTerminated);
        end
    end
    
end

