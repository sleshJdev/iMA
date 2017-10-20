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
        function request = createDesignPointRequest(payload)
            request = org.json.JSONObject();
            request.put('command', 'create-design-point');
            request.put('payload', payload);
        end
        function request = openProjectRequest(projectPath)
            payload = org.json.JSONObject();
            payload.putString('projectPath', projectPath);
            request = org.json.JSONObject();
            request.put('command', 'open-project');
            request.put('payload', payload);            
        end
    end
    
end

