classdef Controller
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        wbclient,
        ansys,
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
    end
    
    methods(Access = public)
        function self = Controller()
            self.config = Controller.loadConfig('C:\Users\User\Documents\MATLAB\iMA\client\config\config.json');            
            self.wbclient = WBClient(self.config);
            self.ansys = Ansys(self.config);
        end        
        function setup(self)
            self.ansys.run('C:\Users\User\Documents\MATLAB\iMA\ansys\iMAmodelFerma.wbpj');
        end
        function terminate(self)
            self.terminated = true;
            self.wbclient.stop();           
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
            request = RequestFactory.createSeedRequest();
            response = self.wbclient.makeRequest(request);
            outputVector = response.getJSONObject('payload');
        end      
        function outputVector = getNewOutputVector(self, inputVector)
            request = RequestFactory.createDesignPointRequest(inputVector);
            response = self.wbclient.makeRequest(request);
            outputVector = response.getJSONObject('payload');
        end        
    end  
    
end

