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
            workbenchExeName = self.ansysConfig.getString('exeName');            
            showGui = self.ansysConfig.getBoolean('showGui');
            host = char(self.ansysConfig.getString('host'));
            port = num2str(self.ansysConfig.getInt('port'));
            Logger.info(sprintf(...
                'Starting ANSYS Workbench with a listening sever on %s:%s, project: %s',...
                host, port, char(ansysProjectPath)))            
            
            command = sprintf(...
                '"%%AWP_ROOT182%%\\commonfiles\\IronPython\\ipy.exe" %s\\client\\ansys\\run-ansys.py -H %s -P %s -F "%s" -DE "%s"',... 
                pwd, host, port, char(ansysProjectPath), char(workbenchExeName));
            if ~showGui, command = strcat(command, ' -nowindow -B'); end;            
            Logger.info(sprintf('Ansys run command: %s', command));           
            system(command);       
        end
        function stop(self)      
            Logger.info('Stopping Ansys...');
            command = RequestFactory.createStopAnsysRequest();
            self.wbclient.sendOnly(command);
            Logger.info('Ansys stopped');
        end
    end
end