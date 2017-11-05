classdef Objectivities
    %OBJECTIVITIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = public)
        configs
    end
    
    methods
        function self = Objectivities()
            objectivitiesPath = [pwd, filesep, 'client', filesep, 'objective'];
            self.configs = ConfigsManager(objectivitiesPath);
        end
        function objectiveFunction = createObjectiveFunction(...
                self, objectiveTitle, inParamsMetaInfoMap, outParamsMetaInfoMap)
            configJson = self.configs.readConfig(objectiveTitle);
            objectiveFunctionName = configJson.getString('className');
            objectiveFunctionSettings = configJson.optJSONObject('settings');
            
            weights = Objectivities.getWeights(inParamsMetaInfoMap);
            targets = Objectivities.getTargets(outParamsMetaInfoMap);
            objectiveFunctionConstructor = str2func(char(objectiveFunctionName));
            objectiveFunction = objectiveFunctionConstructor(objectiveFunctionSettings, weights, targets);
        end
    end
    methods(Static)
        function weights = getWeights(inParamsMetaInfoMap)
            paramsMetaInfo = values(inParamsMetaInfoMap);
            weights = zeros(1, inParamsMetaInfoMap.Count);
            for i = 1 : inParamsMetaInfoMap.Count
                metaInfo = paramsMetaInfo{i};
                weights(i) = metaInfo.getDouble('weight');
            end
        end
        function targets = getTargets(outParamsMetaInfoMap)
            paramsMetaInfo = values(outParamsMetaInfoMap);
            targets = cell(1, outParamsMetaInfoMap.Count);
            for i = 1 : outParamsMetaInfoMap.Count
                metaInfo = paramsMetaInfo{i};
                targets{i} = char(metaInfo.getString('target'));
            end
        end
    end
    
end

