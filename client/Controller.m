classdef Controller < handle
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        wbclient,
        ansys,
        config,
        configPath,
        objective,
        terminated,
        algorithm;
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
            self.objective = Multiply;
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
            self.terminated = true;
        end
        function terminated = isTerminated(self)
            terminated = self.terminated;
        end
        function optimizedVector = optimize(self, algorithmName)
            self.terminated = false;            
            self.wbclient.reset();
            seedResponse = self.seed();
            if seedResponse.getInt('status') == 200 % is ok
                seedPayload = seedResponse.getJSONObject('payload');
                self.algorithm = AlgoFactory.create(...
                    self.config.getJSONObject('algorithms').getJSONObject(algorithmName),...
                    seedPayload.getJSONArray('in'),...
                    self.objective.getValue(seedPayload.getJSONArray('out')));
                
                [message, optimizedVector, optimizedValue] = self.algorithm...
                    .start(@self.getNewOutputValue, @Logger.debug);
                
                if strcmpi(message, 'OK')
                    Logger.info(sprintf('>>> Optimized vector: %s(%d)', mat2str(optimizedVector), optimizedValue));
                elseif strcmpi(message, 'CANCELED')
                    Logger.info(sprintf('>>> Canceled by used, current vector: %s(%d)', mat2str(optimizedVector), optimizedValue));
                else
                    Logger.error(message);
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
        function [status, outputValue] = getNewOutputValue(self, inputVector)
            parameters = org.json.JSONArray();
            for i = 1 : length(inputVector)
                param = org.json.JSONObject();
                paramName = strcat(self.wbclient.getAnsysParamPrefix(), num2str(i));
                param.put('name', paramName);
                param.put('value', inputVector(i));
                parameters.put(param);
            end
            payload = org.json.JSONObject();
            payload.put('parameters', parameters);
            request = RequestFactory.createDesignPointRequest(payload);
            self.wbclient.execute(request);
            json = self.wbclient.waitForResponse();
            payload = json.getJSONObject('payload');
            outputParameters = payload.getJSONArray('parameters');
            status = json.getInt('status');
            outputValue = self.objective.getValue(outputParameters);
        end
    end
    
    methods(Static)
        function config = loadConfig(path)
            jsonConfig = fileread(path);
            config = org.json.JSONObject(jsonConfig);
        end
    end
end

