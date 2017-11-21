classdef RequestFactory
    %REQUESTFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function request = createStopAnsysRequest()
            request = 'Exit\n<EOF>';
        end
        function request = createSeedRequest()
            request = org.json.JSONObject('{"command": "seed", "payload": {}}');
        end
        function request = createGetMetadataRequest()
            request = org.json.JSONObject('{"command": "get-metadata", "payload": {}}');
        end
        function request = createDesignPointRequest(paramValues, paramsMetaInfoMap)
            paramsJson = values(paramsMetaInfoMap);
            request = org.json.JSONObject();
            parameters = org.json.JSONArray();
            for i = 1 : length(paramValues)
                paramJson = paramsJson{i};
                param = org.json.JSONObject();
                param.put('name', paramJson.getString('name'));
                param.put('value', sprintf('%d [%s]', paramValues(i), char(paramJson.optString('unit'))));
                parameters.put(param);
            end
            payload = org.json.JSONObject();
            payload.put('parameters', parameters);
            request.put('command', 'create-design-point');
            request.put('payload', payload);
        end
    end
    
end

