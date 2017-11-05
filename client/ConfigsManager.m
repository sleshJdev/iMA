classdef ConfigsManager
    %CONFIGUTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        configFileName = 'config.json'
    end
    properties
        root, mapping;
    end
    
    methods
        function self = ConfigsManager(root)
            self.root = root;
            self.mapping = self.getTitleToKeyMapping(root);
        end
        function [configJson, configPath, key] = readConfig(self, title)
            key = self.mapping(title);
            configPath = self.buildConfigPath(key);
            configJson = JsonUtils.readJsonFile(configPath);
        end
        function path = buildConfigPath(self, key)
            path = [self.root, filesep, key, filesep, self.configFileName];
        end        
        function titles = getTitles(self)
            titles = keys(self.mapping);
        end
        function settings = getSettings(self, title)
            configJson = self.readConfig(title);
            settings = configJson.getJSONObject('settings');
        end
        function applySettings(self, title, settings)                 
            [configJson, configPath, ~] = self.readConfig(title);
            configJson.put('settings', settings);
            JsonUtils.writeToFile(configJson, configPath);
        end
        function mapping = getTitleToKeyMapping(self, root)
            mapping = containers.Map();            
            contents = dir(root);
            for i = 1 : length(contents)
                item = contents(i);
                if ~strcmp(item.name, '.') && ~strcmp(item.name, '..')...
                        && item.isdir && ~strcmp(item.name(1), '_') %_ small trick to disable some items
                    key = item.name;
                    configContent = fileread([root, filesep, key, filesep, self.configFileName]);
                    configJson = org.json.JSONObject(configContent);
                    title = configJson.getString('title');
                    mapping(char(title)) = char(key);
                end
            end
        end
    end
    
end

