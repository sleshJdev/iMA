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
        function terminate(self)
            Logger.info('Terminating of optimization...');
            self.terminated = true;
            if self.wbclient ~= 0
                self.wbclient.terminate();
            end
            if self.algorithm ~= 0
                self.algorithm.terminate();
            end
            Logger.info('Optimization was terminated');
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
        function fetchMetadata(self)
            try
                Logger.info('Fetching information about parameters...');
                request = RequestFactory.createGetMetadataRequest();
                self.wbclient.reset();
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
                
                Controller.printInParametersSettings(self.inParamsMetaInfoMap);
                Controller.printOutParametersSettings(self.outParamsMetaInfoMap);
                
                Logger.info('Information about parameters was fetched successfully');
            catch e
                Logger.error('Problem when fetching a metadata. Loot at details: ');
                Logger.error(e);
                rethrow(e);
            end
        end
        function optimizedVector = optimize(self, algorithmTitle, objectiveTitle)
            Logger.info('Optimization started');
            self.reset();

            Logger.info('Seed design point processing...');
            seedResponse = self.seed();
            status = seedResponse.getInt('status');
            if status ~= 200 % is something wrong
                Logger.error(['Cannot fetch seed data: ', char(seedResponse.getString('message'))]);
                return;
            end
            
            seedPayload = seedResponse.getJSONObject('payload');
            
            self.objective = self.objectivities.createObjectiveFunction(...
                objectiveTitle, self.inParamsMetaInfoMap, self.outParamsMetaInfoMap);
            
            outputParams = JsonUtils.sortParams(seedPayload.getJSONArray('out'));
            outputParamValues = JsonUtils.mapArrayToNumbers(outputParams, 'value');
            initialValue = self.objective.getValue(outputParamValues);
            
            Logger.info(['Initial value: ', num2str(initialValue)]);
            inputParams = JsonUtils.sortParams(seedPayload.getJSONArray('in'));
            self.algorithm = self.algorithms.createAlgorithm(...
                algorithmTitle, inputParams, initialValue, self.inParamsMetaInfoMap);
            Logger.info('Seed design point was processed');
            
            Controller.printInParametersSettings(self.inParamsMetaInfoMap);
            Controller.printOutParametersSettings(self.outParamsMetaInfoMap);
            
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
            Logger.info('Optimized done');
        end
    end
    
    methods(Access = private)
        function seedResponse = seed(self)
            request = RequestFactory.createSeedRequest();
            self.wbclient.execute(request);
            seedResponse = self.wbclient.waitForResponse();
        end
        function [status, outputValue, outputParamValues] = getNewOutputValue(self, paramValues)
            request = RequestFactory.createDesignPointRequest(...
                paramValues, self.inParamsMetaInfoMap);
            self.wbclient.execute(request);
            json = self.wbclient.waitForResponse();
            status = json.getInt('status');
            payload = json.getJSONObject('payload');
            if status == 200
                outputParams = payload.getJSONArray('parameters');
                outputParamValues = JsonUtils.mapArrayToNumbers(outputParams, 'value');
                outputValue = self.objective.getValue(outputParamValues);
            else
                Logger.error(['Error when computing design point: ', char(json.getString('message'))]);
                outputValue = 0;
                outputParamValues = 0;
            end
        end
    end
    
    methods(Static)
        function printInParametersSettings(inParamsMetaInfoMap)
            Logger.info('Input parameters settings: ');
            paramNames = keys(inParamsMetaInfoMap);
            for i = 1 : inParamsMetaInfoMap.Count
                paramName = paramNames{i};
                paramConf = inParamsMetaInfoMap(paramName);
                Logger.info([char(paramConf.getString('displayText')), '(', paramName, '): ',...
                    ', Step size = ', num2str(paramConf.getDouble('stepSize')),...
                    ', Weight = ', num2str(paramConf.getDouble('weight')),...
                    ', Min value = ', num2str(paramConf.getDouble('minValue')),...
                    ', Max value = ', num2str(paramConf.getDouble('maxValue'))]);
            end
            
        end
        function printOutParametersSettings(outParamsMetaInfoMap)
            Logger.info('Output parameters settings: ');
            paramNames = keys(outParamsMetaInfoMap);
            for i = 1 : outParamsMetaInfoMap.Count
                paramName = paramNames{i};
                paramConf = outParamsMetaInfoMap(paramName);
                Logger.info([char(paramConf.getString('displayText')), '(', paramName, ') : ',...
                    ', target = ', char(paramConf.getString('target'))]);
            end
        end
        function config = loadConfig(path)
            jsonConfig = fileread(path);
            config = org.json.JSONObject(jsonConfig);
        end
    end
end

