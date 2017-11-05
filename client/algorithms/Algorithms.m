classdef Algorithms < handle
    %ALGORITHM Summary of this class goes here
    %   Detailed explanation goes here    
    properties(Access = public)
        configs
    end
    
    methods(Access = public)
        function self = Algorithms()
            algosPath = [pwd, filesep, 'client', filesep, 'algorithms'];
            self.configs = ConfigsManager(algosPath);     
        end        
        function algorithm = createAlgorithm(...
                self, algorithmTitle, initialPrameters, initialValue, inParamsMetaInfoMap)
            configJson = self.configs.readConfig(algorithmTitle);
            algorithmClassName = configJson.getString('className');
            algorithmSettings = configJson.getJSONObject('settings');
            
            algorithmContructor = str2func(char(algorithmClassName));
            % parsing of starting point, initial value, lower and upper bounds
            numberDimensions = initialPrameters.length();
            startPoint = zeros(numberDimensions, 1);
            stepSizes = zeros(numberDimensions, 1);
            lowerBound = zeros(numberDimensions, 1);
            upperBound = zeros(numberDimensions, 1);
            for i = 1 : numberDimensions
                parameter = initialPrameters.getJSONObject(i - 1);
                parameterMeta = inParamsMetaInfoMap(char(parameter.getString('name')));
                stepSizes(i) = parameterMeta.getDouble('stepSize');
                lowerBound(i) = parameterMeta.getDouble('minValue');
                upperBound(i) = parameterMeta.getDouble('maxValue');
                startPoint(i) = parameter.getDouble('value');
            end
            algorithm = algorithmContructor(...
                algorithmSettings, startPoint, initialValue,...
                stepSizes, lowerBound, upperBound);
        end        
    end
end

