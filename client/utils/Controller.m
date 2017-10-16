classdef Controller
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        communicator,
        ansysRunner,
        config,
        terminated = false
    end
    
    methods
        function config = get.config(self)
            config = self.config;
        end
    end
    
    methods(Static)
        function config = loadConfig(path)
            jsonConfig = fileread(path);
            config = org.json.JSONObject(jsonConfig);
        end
        function request = createSeedRequest()
            request = org.json.JSONObject('{"command": "seed", "payload": {}');
        end
        function request = createDesignPointRequest(payload)
            request = org.json.JSONObject();
            request.put('command', 'create-design-point');
            request.put('payload', payload);
        end
    end
    
    methods(Access = public)
        function self = Controller()
            self.config = Controller.loadConfig('C:\Users\User\Documents\MATLAB\iMA\client\config\config.json');            
            mediatorConfig = self.config.getJSONObject('mediator');
            self.communicator = Communicator(...
                mediatorConfig.getString('host'),... 
                mediatorConfig.getInt('port'));
            
            clientConfig = self.config.getJSONObject('client');
            self.ansysRunner = AnsysRunner(...
                char(clientConfig.getString('ansysExePath')),...
                char(clientConfig.getString('mediatorAppPath')),...
                char(clientConfig.getString('ansysProjectPath')));
        end        
        function setup(self)
            self.ansysRunner.run();
            self.communicator.connect();
        end
        function terminate(self)
            self.terminated = true;
            self.communicator.stop();           
        end
        function optimizedVector = optimize(self, algorithmName)            
            algorithmsConfig = self.config.getJSONObject('algorithms');
            algorithmConfig = algorithmsConfig.getJSONObject(algorithmName);           
            algorithm = Algorithm(algorithmConfig);
            initialOutputVector = self.seed();                
            [error, optimizedVector] = algorithm.run(initialOutputVector, @self.getNewOutputVector);
            if ~isempty(error)
                Logger.error(error);
            end
        end
        function value = isTerminated(self)
            value = self.terminated;
        end
        function outputVector = seed(self)
            request = Controller.createSeedRequest();
            response = self.communicator.makeRequest(request);
            outputVector = response.getJSONObject('payload');
        end      
        function outputVector = getNewOutputVector(self, inputVector)
            request = Controller.createDesignPointRequest(inputVector);
            response = self.makeRequest(request);
            outputVector = response.getJSONObject('payload');
        end        
    end  
    
end

