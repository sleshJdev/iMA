classdef JsonAdapter
    %JSONADAPTER Represents wrapper of org.json.JSONObject
    %       Provide methods to read properties from org.json.JSONObject
    %   and perform type casting to Matlab types.
    %       For example:
    %   JSONObject.getString('propertyName') returns java.lang.String which
    %   is incopatible with Matlab types. To get string from json object
    %   call the Adapter.getString('propertyName') method, whihc will make
    %   casting to 'char' type by invoking char('...') function.
    %   The same integers, doubles and arrays
    
    properties
        sourceJson
    end
    
    methods
        function self = JsonObjectAdapter(json)
            self.sourceJson = json;
        end
        function string = getString(self, propertyName)
            string = char(self.sourceJson.getString(propertyName));
        end
        function result = getStringArray(self, propertyName)
            jsonArray = self.sourceJson.getJSONArray(propertyName);
            result = zeros(1, jsonArray.length());
            for i = 1 : jsonArray.length()                
                result(i) = char(jsonArray.getString(i - 1));
            end
        end 
    end
    
end

