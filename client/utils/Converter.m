classdef Converter
    methods(Static)
        function result = parseJsonArray(jsonArray)
            result = zeros(1, jsonArray.length());
            for i = 1 : jsonArray.length()                
                result(i) = jsonArray.get(i - 1);
            end
        end
    end
end

