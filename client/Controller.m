classdef Controller
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        wbclient,
        ansys,
        config,
        configPath
    end
    
    methods
        function config = get.config(self)
            config = self.config;
        end
    end    
    
    methods(Access = public)
        function self = Controller()
            self.configPath = sprintf('%s\\config\\config.json', pwd);
            self.config = Controller.loadConfig(self.configPath);            
            self.wbclient = WBClient(self.config);
            self.ansys = Ansys(self.config);
        end        
        function runAnsys(self, ansysProjectPath)
            self.ansys.run(ansysProjectPath);            
        end
        function connect(self)
            self.wbclient.setup();
        end
        function stopAnsys(self)
            self.ansys.stop();
        end
        function terminate(self)
            self.wbclient.terminate();  
        end
        function optimizedVector = optimize(self, algorithmName)            
            algorithmsConfig = self.config.getJSONObject('algorithms');
            algorithmConfig = algorithmsConfig.getJSONObject(algorithmName);           
            algorithm = Algorithm(algorithmConfig);
            self.wbclient.reset();
            seedResponse = self.seed(); 
            ok = seedResponse.getInt('status') == 200;
            if ok
                seedPayload = seedResponse.getJSONObject('payload');
                [error, optimizedVector] = algorithm.run(...
                    seedPayload, @(inputVector)self.getNewOutputVector(inputVector));
                if ~isempty(error)
                    Logger.error(error);
                else 
                    Logger.info(sprintf('>>> Optimized vector: %s', mat2str(optimizedVector)));
                end
            else
                Logger.error(seedResponse.getString('message'));
            end
        end       
        function json = seed(self)
            request = RequestFactory.createSeedRequest();
            self.wbclient.execute(request);
            json = self.wbclient.waitForResponse();   
        end      
        function outputVector = getNewOutputVector(self, inputVector)
            request = RequestFactory.createDesignPointRequest(inputVector);
            self.wbclient.execute(request);
            json = self.wbclient.waitForResponse();
            outputVector = json.getJSONObject('payload');
        end        
    end  
    
    methods(Static)
        function config = loadConfig(path)
            jsonConfig = fileread(path);
            config = org.json.JSONObject(jsonConfig);
        end        
    end    
end

