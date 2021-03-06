classdef JsonUtils
    %JSONADAPTER Represents wrapper of org.json.JSONObject
    %       Provide methods to read properties from org.json.JSONObject
    %   and perform type casting to Matlab types.
    %       For example:
    %   JSONObject.getString('propertyName') returns java.lang.String which
    %   is incopatible with Matlab types. To get string from json object
    %   call the Adapter.getString('propertyName') method, whihc will make
    %   casting to 'char' type by invoking char('...') function.
    %   The same for vectors.
    
    properties
    end
    
    methods(Static)
        function printOutoutParametersInfo()
            
        end
        
        function paramsMap = createParametersMap(jsonParams)
            paramsMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for i = 1 : jsonParams.length()
                jsonParam = jsonParams.getJSONObject(i - 1);
                jsonParam.put('weight', 1.0);
                jsonParam.put('stepSize', 1.0);
                jsonParam.put('target', 'min');
                name = char(jsonParam.getString('name'));
                paramsMap(name) = jsonParam;
            end
        end
        function json = readJsonFile(filePath)
            jsonText = fileread(filePath);
            json = org.json.JSONObject(jsonText);
        end
        function writeToFile(json, filePath)
            writer = 0;
            try
                writer = java.io.FileWriter(filePath);
                json.write(writer, 4, 0);
                writer.close();
            catch e
                if writer ~= 0
                    writer.close();
                end
                rethrow(e);
            end
        end
        function string = getString(source, propertyName)
            string = char(source.getString(propertyName));
        end
        function vector = mapArrayToNumbers(jsonArray, propertyName)
            vector = zeros(1, jsonArray.length());
            for i = 1 : jsonArray.length()
                item = jsonArray.getJSONObject(i - 1);
                if ~item.isNull(propertyName)
                    vector(i) = item.getDouble(propertyName);
                end
            end
        end
        function vector = mapArrayToStrings(jsonArray, propertyName)
            vector = cell(1, jsonArray.length());
            for i = 1 : jsonArray.length()
                item = jsonArray.getJSONObject(i - 1);
                if item.isNull(propertyName)
                    vector{i} = '';
                else
                    vector{i} = char(item.getString(propertyName));
                end
            end
        end
        function sortedParams = sortParams(params)
            indexes = zeros(params.length(), 1);
            for i = 1 : params.length()
                param = params.getJSONObject(i - 1);
                name = param.getString('name');
                index = str2double(regexp(char(name), '\d+', 'match'));
                indexes(i) = index;
            end
            [~, transpositions] = sort(indexes);
            sortedParams = org.json.JSONArray();
            for i = 1 : params.length();
                from = transpositions(i) - 1;
                sortedParams.put(params.getJSONObject(from));
            end
        end
    end
    
end

