classdef Additivity
    %MULTIPLY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        settings, weights, targets
    end   
    
    methods
        function self = Additivity(settings, weights, targets)
            self.settings = settings;
            self.weights = weights;
            self.targets = targets;
        end
        function result = getValue(self, outParamValues)
            result = 0;            
            for i = 1 : length(outParamValues)
                if isequal(self.targets{i}, 'min')
                    result = result + self.weights(i) * outParamValues(i);
                elseif isequal(self.targets{i}, 'max')
                    if outParamValues(i) ~= 0
                        result = result + (self.weights(i) * (1 / outParamValues(i)));
                    end                    
                end
            end
        end
    end
    
end

