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
        function vector = getNumberVector(source, propertyName)
            jsonArray = source.getJSONArray(propertyName);
            vector = zeros(1, jsonArray.length());
            for i = 1 : jsonArray.length()                
                vector(i) = char(jsonArray.getDouble(i - 1));
            end
        end 
        function vector = getStringVector(source, propertyName)
            jsonArray = source.getJSONArray(propertyName);
            vector = cell(1, jsonArray.length());
            for i = 1 : jsonArray.length()                
                vector{i} = char(jsonArray.getString(i - 1));
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

