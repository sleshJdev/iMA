classdef Multiply
    %MULTIPLY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        settings, weights, targets
    end   
    
    methods
        function self = Multiply(settings, weights, targets)
            self.settings = settings;
            self.weights = weights;
            self.targets = targets;
        end
        function result = getValue(self, outParamValues)
            minValue = min(outParamValues);
            normalized = (outParamValues - minValue) / minValue;
            result = 1;
            for i = 1 : length(normalized)
                if isequal(self.targets{i}, 'min')
                    result = result * self.weights(i) * normalized(i);
                elseif isequal(self.targets{i}, 'max')
                    if normalized(i) ~= 0
                        result = result * self.weights(i) * 1 / normalized(i);
                    end                    
                end
            end
        end
    end
    
end

