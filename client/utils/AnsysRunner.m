classdef AnsysRunner
    %ANSYSRUNNER Replesent interface to run AnsysWorkbench and pass to him
    %            IronPython script(Mediator) and ansys project
    
    properties (Access = private)
        ansysExePath;
        ansysProjectPath;
        mediatorAppPath;
    end
    
    methods(Access = private)
        function [command] = buildRunCommand(self)
            command = sprintf('"%s" -I -R %s -F %s',...
                            self.ansysExePath,...
                            self.mediatorAppPath,... 
                            self.ansysProjectPath);
        end       
    end
    
    methods(Access = public)
        function self = AnsysRunner(ansysExePath, mediatorAppPath, ansysProjectPath)
            self.ansysExePath = ansysExePath;
            self.mediatorAppPath = mediatorAppPath;
            self.ansysProjectPath = ansysProjectPath;            
        end
        function run(self)
            command = self.buildRunCommand();            
            Logger.info(sprintf('Ansys run command: %s', command));           
            system(command);                
        end        
    end
end