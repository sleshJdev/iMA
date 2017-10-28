classdef Multiply
    %MULTIPLY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function value = getValue(outParameters)
            value = 1;
            for i = 1 : outParameters.length()
                param = outParameters.getJSONObject(i - 1);
                value = value * param.getDouble('value');
            end
        end
    end
    
end

