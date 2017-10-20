classdef Algorithm < handle
    %ALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        algorithmFunction,
        algorithmSettings
    end
    
    methods(Access = public)
        function self = Algorithm(algorithmConfig)
            algorithmFunctionName = algorithmConfig.getString('algorithmFunctionName');
            self.algorithmFunction = str2func(char(algorithmFunctionName));            
            self.algorithmSettings = algorithmConfig.getJSONObject('settings');
        end
        function [error, optimizedVector] = run(self, initialOutputVector, getNewOutputVector)                       
            [error, optimizedVector] = self.algorithmFunction(...
                self.algorithmSettings, initialOutputVector, getNewOutputVector);
        end
    end
    
end

