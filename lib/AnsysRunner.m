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
        function [totalDeformation] = update(this, inVector)
            global PROPERTIES;  
            
            disp('inVector in update method');
            disp(inVector);
            
            excel = Excel(fullfile(PROPERTIES.excelSheetPath, PROPERTIES.excelSheetName));
            excel.writeParameters(inVector);       
            
            commandFile = fopen(strcat(PROPERTIES.workDirectoryPath, '\ansys\listenme\ansys_command.txt'), 'w');
            fprintf(commandFile, '%s', 'update');
            fclose('all');            
            
            % reset command file for matalb
            path = strcat(PROPERTIES.workDirectoryPath, '\ansys\listenme\matlab_command.txt');
            fprintf('reset command file for matlab \n');
            commandFile = fopen(path, 'w');
            fprintf(commandFile, '%s', 'wait');% simply stub
            fclose('all');
            
            % wait while ansys calculate            
            value = fileread(path);
            step = 1;
            while ~strcmp(value, 'end')
                pause(2);
                fprintf('step %d value %s\n', step, value);
                step = step + 1;
                value = fileread(path);
            end                       
            
            % return totalDeforamtion as criteria of optimization
            outVector = excel.readParameters();
            totalDeformation = outVector(1);
            Logger.info(sprintf('AnsysRunner    update    get totatl deformation: %s', num2str(totalDeformation)));            
        end
    end
end