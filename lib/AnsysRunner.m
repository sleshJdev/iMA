classdef AnsysRunner
    %ANSYSRUNNER Replesent interface to run AnsysWorkbench and pass to him
    %            IronPython script and ansys project
    
    properties (Access = private)
        ansysExePath;
        ansysProjectPath;
        scriptPath;
        matlabCommandPath;
        ansysCommandPath;
        excel
    end
    
    methods(Access = private)
        function [command] = buildRunCommand(this)
            command = sprintf('"%s" -I -R %s -F %s', this.ansysExePath, this.scriptPath, this.ansysProjectPath);
        end
        function setCommand(this, commandFor, command)
            commandFile = fopen(commandFor, 'w');
            fprintf(commandFile, '%s', command);
            fclose('all');   
        end
        function waitWhileAnsysCalculate(this)                       
            counter = 1;
            pauseDuration = 5;
            value = fileread(this.matlabCommandPath);            
            while ~strcmp(value, 'make-optimization')
                pause(pauseDuration);
                fprintf('%d seconds\n', pauseDuration * counter);
                counter = counter + 1;
                value = fileread(this.matlabCommandPath);
            end 
            pause(pauseDuration);
        end
    end
    
    methods
        function this = AnsysRunner(ansysExePath, scriptPath, ansysProjectPath)
            global PROPERTIES
            this.ansysExePath = ansysExePath;
            this.scriptPath = scriptPath;
            this.ansysProjectPath = ansysProjectPath;
            this.matlabCommandPath = strcat(PROPERTIES.workDirectoryPath, '\ansys\listenme\matlab_command.txt');
            this.ansysCommandPath = strcat(PROPERTIES.workDirectoryPath, '\ansys\listenme\ansys_command.txt');
            this.excel = Excel(fullfile(PROPERTIES.excelSheetPath, PROPERTIES.excelSheetName));
        end
        function run(this)    
            command = this.buildRunCommand();     
            
            Logger.info(sprintf('ansys run command: %s', command));    
            
            system(command);                
        end   
        function [targetValue] = update(this, inVector)         
            % write new parameters to ansys            
            this.excel.writeParameters(inVector);      
            
%             Logger.info('input parameters: %s\n', mat2str(inVector));                      
            
            % reset command file for matalb
            this.setCommand(this.matlabCommandPath, 'wait');
            
            % update ansys with new parameters
            this.setCommand(this.ansysCommandPath, 'update');          
            
            % waiting
            this.waitWhileAnsysCalculate();
            
            % return totalDeforamtion and geometryMass as criteria of optimization
            outVector = this.excel.readParameters();
            totalDeformation = outVector(1);
            geometryMass = outVector(2);
            targetValue = totalDeformation * geometryMass;
            Logger.info(sprintf('AnsysRunner    update    totatl deformation: %s, mass: %s, targetValue: %s\n',...
                                 num2str(totalDeformation), num2str(geometryMass), num2str(targetValue)));            
        end        
    end
end