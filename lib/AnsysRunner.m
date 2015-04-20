classdef AnsysRunner
    %ANSYSRUNNER Replesent interface to run AnsysWorkbench and pass to him
    %            IronPython script and ansys project
    
    properties (Access = private)
        ansysExePath;
        ansysProjectPath;
        scriptPath;
    end
    
    methods(Access = private)
        function [command] = buildRunCommand(this)
            command = sprintf('"%s" -I -R %s -F %s', this.ansysExePath, this.scriptPath, this.ansysProjectPath);
        end
    end
    
    methods
        function this = AnsysRunner(ansysExePath, scriptPath, ansysProjectPath)
            this.ansysExePath = ansysExePath;
            this.scriptPath = scriptPath;
            this.ansysProjectPath = ansysProjectPath;
        end
        function run(this)    
            command = this.buildRunCommand();          
            
            disp(command);
            Logger.info(sprintf('AnsysRunner    run    command: %s', command));    
            
            system(command);                
        end        
        function [totalDeformation] = Update(this, inVector)
            global PROPERTIES;   
            
            excel = Excel(fullfile(PROPERTIES.excelSheetPath, PROPERTIES.excelSheetName));
            
            excel.setValueOfParameter('Length', inVector(1));
            excel.setValueOfParameter('Width', inVector(2));
            excel.setValueOfParameter('Height', inVector(3));   
            
            commandFile = fopen(strcat(PROPERTIES.workDirectoryPath, '\ansys\listenme\command.txt'), 'w');
            fprintf(commandFile, '%s', 'update');
            fclose('all');
            
            totalDeformation = excel.getValueOfParameter('Deformation');
        end
    end
end