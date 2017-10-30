classdef Algorithms < handle
    %ALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    properties(Access = private)
        mapping
    end
    methods(Access = public)
        function self = Algorithms()
            self.mapping = Algorithms.getAlgorithmsMapping();
        end
        function titles = getAlgorithmTitles(self)
            titles = self.mapping(:, 4);
        end
        function algorithm = createAlgorithm(self, algorithmTitle, initialPrameters, initialValue)
            algoMapping = self.findAlgorithmMappingByTitle(algorithmTitle);
            algorithmClassName = algoMapping{2};
            algorithmContructor = str2func(char(algorithmClassName));
            algorithmSettings = algoMapping{3};
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
    end
    methods(Access = private)
        function mapping = findAlgorithmMappingByTitle(self, title)
            for i = 1 : size(self.mapping, 1)
                tuple = self.mapping(i, :);
                if strcmp(tuple(4), title)
                    mapping = tuple;
                    return;
                end
            end
        end
    end
    methods(Static)
        function mapping = getAlgorithmsMapping()
            mapping = {};
            algosPath = [pwd, filesep, 'client', filesep, 'algorithms'];
            contents = dir(algosPath);
            for i = 1 : length(contents)
                item = contents(i);
                if ~strcmp(item.name, '.') && ~strcmp(item.name, '..')...
                        && ~strcmp(item.name(1), '_') && item.isdir
                    algoKey = item.name;
                    configContent = fileread([algosPath, filesep, algoKey, filesep, 'config.json']);
                    configJson = org.json.JSONObject(configContent);
                    title = configJson.getString('title');
                    className = configJson.getString('className');
                    settings = configJson.getJSONObject('settings');
                    mapping(end + 1, :) = {algoKey, char(className), settings, char(title)};
                end
            end
        end
    end
end

