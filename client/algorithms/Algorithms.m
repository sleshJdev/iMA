classdef Algorithms < handle
    %ALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)
        configFileName = 'config.json'
    end
    properties(Access = private)
        mapping, algosPath
    end
    methods(Access = public)
        function self = Algorithms()
            self.algosPath = [pwd, filesep, 'client', filesep, 'algorithms'];
            self.mapping = self.getAlgorithmsKeyTitleMapping(self.algosPath);        
        end
        function titles = getAlgorithmTitles(self)
            titles = keys(self.mapping);
        end
        function algorithm = createAlgorithm(self, algorithmTitle, initialPrameters, initialValue)
            configJson = self.getAlgorithmConfig(algorithmTitle);
            algorithmClassName = configJson.getString('className');
            algorithmSettings = configJson.getJSONObject('settings');
            
            algorithmContructor = str2func(char(algorithmClassName));
            % parsing of starting point, initial value, lower and upper bounds
            params = JsonUtils.sortParams(initialPrameters);
            numberDimensions = params.length();
            startPoint = zeros(numberDimensions, 1);
            lowerBound = zeros(numberDimensions, 1);
            upperBound = zeros(numberDimensions, 1);
            for i = 1 : numberDimensions
                parameter = params.getJSONObject(i - 1);
                lowerBound(i) = parameter.getDouble('minValue');
                upperBound(i) = parameter.getDouble('maxValue');
                startPoint(i) = parameter.getDouble('value');
            end
            algorithm = algorithmContructor(...
                algorithmSettings, startPoint, initialValue, lowerBound, upperBound);
        end
        function settings = getAlgorithmSettings(self, algoTitle)
            configJson = self.getAlgorithmConfig(algoTitle);
            settings = configJson.getJSONObject('settings');
        end
        function applyAlgorithmSettings(self, algoTitle, settings)                 
            [configJson, configPath, ~] = self.getAlgorithmConfig(algoTitle);
            configJson.put('settings', settings);
            JsonUtils.writeToFile(configJson, configPath);
        end
    end
    methods(Access = private)        
        function [configJson, configPath, algoKey] = getAlgorithmConfig(self, algoTitle)
            algoKey = self.mapping(algoTitle);
            configPath = self.buildAlgorithmConfigPath(algoKey);
            configJson = JsonUtils.readJsonFile(configPath);
        end
        function path = buildAlgorithmConfigPath(self, algoKey)
            path = [self.algosPath, filesep, algoKey, filesep, self.configFileName];
        end
        function mapping = getAlgorithmsKeyTitleMapping(self, algosPath)
            mapping = containers.Map();            
            contents = dir(algosPath);
            for i = 1 : length(contents)
                item = contents(i);
                if ~strcmp(item.name, '.') && ~strcmp(item.name, '..')...
                        && item.isdir && ~strcmp(item.name(1), '_') %_ small trick to disable some algorithm
                    algoKey = item.name;
                    configContent = fileread([algosPath, filesep, algoKey, filesep, self.configFileName]);
                    configJson = org.json.JSONObject(configContent);
                    title = configJson.getString('title');
                    mapping(char(title)) = char(algoKey);
                end
            end
        end
    end
end

