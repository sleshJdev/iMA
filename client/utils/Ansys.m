classdef Ansys
    %ANSYSRUNNER Replesent interface to run AnsysWorkbench and pass to him
    %            IronPython script(Mediator) and ansys project
    
    properties (Access = private)
        ansysConfig, wbclient
    end
    
    methods(Access = public)
        function self = Ansys(config)
            self.ansysConfig = config.getJSONObject('ansys');
            self.wbclient = WBClient(config);
        end
        function run(self, ansysProjectPath)
            ansysFrameworkPath = fullfile(getenv('AWP_ROOT182'), 'Framework/bin/Win64');
            workbenchExeName = self.ansysConfig.getString('exeName');
            workbenchExeFullPath = fullfile(char(ansysFrameworkPath), char(workbenchExeName));        

            showGui = self.ansysConfig.getBoolean('showGui');
            host = char(self.ansysConfig.getString('host'));
            port = num2str(self.ansysConfig.getInt('port'));
            Logger.info(sprintf(...
                'Starting ANSYS Workbench with a listening sever on %s:%s, project: %s',...
                host, port, char(ansysProjectPath)))            

            command = sprintf('"%s" -H %s -P %s -F "%s" ', workbenchExeFullPath, host, port, char(ansysProjectPath));
            if ~showGui, command = strcat(command, ' -nowindow -B'); end;            
            Logger.info(sprintf('Ansys run command: %s', command));           
            system(command);                
        end
    end
end