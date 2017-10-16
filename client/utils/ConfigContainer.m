classdef ConfigContainer < handle
    %CONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        path,
        config
    end
    
    methods(Static)
        function config = loadConfig(path)
            jsonConfig = fileread(path);
            config = org.json.JSONObject(jsonConfig);
        end
    end
    methods
        function config = get.config(self)
            config = self.config;
        end
    end
    methods
        function self = ConfigContainer(path)
            self.path = path;
            self.config = ConfigContainer.loadConfig(path);
        end
        % propertyPath - dot separated path to target property
%         function set(self, propertyPath, value)
%             keys = strsplit(propertyPath, '.');
%             propertyName = keys(end);
%             keys = keys(1:end-1);
%             if isempty(keys)
%                 self.config.put(propertyName, value);
%             else
%                 key = keys(1);
%                 config = self.config.get
%                 for i = 1:length(keys)
%                     config
%                 end
%             end
%         end
        function setAnsysProjectPath(self, path)
            clientConfig = self.config.getObject('client');
            clientConfig.put('ansysProjectPath', path);
            self.save();
        end
        function setAnsysExePath(self, path)
            clientConfig = self.config.getObject('client');
            clientConfig.put('ansysExePath', path);
            self.save();
        end
        function setMediatorAppPath(self, path)
            clientConfig = self.config.getObject('client');
            clientConfig.put('mediatorAppPath', path);
            self.save();
        end
        function reload(self)
            self.config = ConfigContainer.loadConfig(self.path);
        end
        function save(self)
            file = fopen(self.path, 'w');
            try
                fprintf(file, '%s', char(self.config.toString(4)));
            catch e
                Logger.error(e)
            end;
            if ~isempty(file)
                fclose(file);
            end
        end
    end
    
end

