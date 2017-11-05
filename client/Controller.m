classdef Controller < handle
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = public)
        ansys, wbclient,
        algorithms, objectivities,
        inParamsMetaInfoMap, outParamsMetaInfoMap,
        config
    end
    
    properties(Access = private)
        algorithm = 0, objective = 0,
        configPath, terminated
    end
    
    methods(Access = public)
        function self = Controller()
            self.configPath = [pwd, filesep, 'config', filesep, 'config.json'];
            self.config = Controller.loadConfig(self.configPath);
            self.wbclient = WBClient(self.config);
            self.ansys = Ansys(self.config);
            self.objectivities = Objectivities();
            self.algorithms = Algorithms();
        end       
        function connect(self)
            self.wbclient.setup();
            self.fetchMetadata();
        end
        function terminate(self)
            self.terminated = true;
            if self.wbclient ~= 0
                self.wbclient.terminate();
            end
            if self.algorithm ~= 0
                self.algorithm.terminate();
            end            
        end
        function reset(self)
            self.terminated = false;
            self.objective = 0;
            self.algorithm = 0;
            self.wbclient.reset();
        end
        function terminated = isTerminated(self)
            terminated = self.terminated;
        end
        function optimizedVector = optimize(self, algorithmTitle, objectiveTitle)
            self.reset();
            seedResponse = self.seed();
            if seedResponse.getInt('status') ~= 200 % is something wrong
                Logger.error(['Cannot fetch seed data: ', char(seedResponse.getString('message'))]);
                return;
            end
            seedPayload = seedResponse.getJSONObject('payload');
            inputParams = JsonUtils.sortParams(seedPayload.getJSONArray('in'));
            outputParams = JsonUtils.sortParams(seedPayload.getJSONArray('out'));
            
            self.objective = self.objectivities.createObjectiveFunction(...
                objectiveTitle, self.inParamsMetaInfoMap, self.outParamsMetaInfoMap);
            initialValue = self.objective.getValue(outputParams);
            self.algorithm = self.algorithms.createAlgorithm(...
                algorithmTitle, inputParams, initialValue, self.inParamsMetaInfoMap);
            
            [message, optimizedVector, optimizedValue] = self.algorithm.start(...
                @self.getNewOutputValue, @Logger.info);
            
            if strcmpi(message, 'OK')
                Logger.info(sprintf('>>> Optimized vector: %s(%d)', mat2str(optimizedVector), optimizedValue));
            elseif strcmpi(message, 'CANCELED')
                Logger.info(sprintf('>>> Canceled by used, current vector: %s(%d)', mat2str(optimizedVector), optimizedValue));
            elseif strcmpi(message, 'ABROAD')
                Logger.info(sprintf('>>> Abroaded, current vector: %s(%d)', mat2str(optimizedVector), optimizedValue));
            else
                Logger.error(message);
            end
        end
    end
    
    methods(Access = private)
        function fetchMetadata(self)
            request = RequestFactory.createGetMetadataRequest();
            self.wbclient.execute(request);
            metadataResponse = self.wbclient.waitForResponse();
            if metadataResponse.getInt('status') ~= 200
                Logger.error(['Cannot fetch metadata: ', char(metadataResponse.getString('message'))]);
                return;
            end
            metadataJson = metadataResponse.getJSONObject('payload');
            inputParams = JsonUtils.sortParams(metadataJson.getJSONArray('in'));
            outputParams = JsonUtils.sortParams(metadataJson.getJSONArray('out'));
            self.inParamsMetaInfoMap = JsonUtils.createParametersMap(inputParams);
            self.outParamsMetaInfoMap = JsonUtils.createParametersMap(outputParams);
            Logger.info('Metadata was fetched successfully');
            Logger.info(['Input parameters: ', char(self.inParamsMetaInfoMap)]);
            Logger.info(['Output parameters: ', char(self.outParamsMetaInfoMap)]);
        end
        function json = seed(self)
            request = RequestFactory.createSeedRequest();
            self.wbclient.execute(request);
            json = self.wbclient.waitForResponse();
        end
        function [status, outputValue] = getNewOutputValue(self, paramValues)
            request = RequestFactory.createDesignPointRequest(...
                paramValues, self.inParamsMetaInfoMap);
            self.wbclient.execute(request);
            json = self.wbclient.waitForResponse();
            status = json.getInt('status');
            payload = json.getJSONObject('payload');
            if status == 200
                outputParameters = payload.getJSONArray('parameters');
                outputValue = self.objective.getValue(outputParameters);
            else
                Logger.error(json.getString('message'));
                outputValue = 0;
            end
        end
    end
    
    methods(Static)
        function config = loadConfig(path)
            jsonConfig = fileread(path);
            config = org.json.JSONObject(jsonConfig);
        end
    end
end

