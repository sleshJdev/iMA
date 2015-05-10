classdef AnsysRunner
    %ANSYSRUNNER Replesent interface to run AnsysWorkbench and pass to him
    %            IronPython script and ansys project
    
    properties (Access = private)
        ansysExePath;
        ansysProjectPath;
        scriptPath;
        matlabCommandPath;
        ansysCommandPath;
        xmlWorker;
    end
    
    methods(Access = private)
        function [command] = buildRunCommand(this)
            command = sprintf('"%s" -I -R %s -F %s', this.ansysExePath, this.scriptPath, this.ansysProjectPath);
        end
        function setCommand(this, commandFor, command)            
            commandFile = fopen(char(commandFor), 'w');
            fprintf(commandFile, '%s', command);
            fclose('all');   
        end
        function time =  waitWhileAnsysCalculate(this)                       
            counter = 1;
            pauseDuration = 5;
            value = fileread(this.matlabCommandPath);            
            while ~strcmp(value, 'optimize')
                pause(pauseDuration);                 
                counter = counter + 1;
                value = fileread(this.matlabCommandPath);
            end      
            time = counter * pauseDuration;            
        end
    end
    
    methods
        function this = AnsysRunner(ansysExePath, scriptPath, ansysProjectPath)
            global PROPERTIES
            this.ansysExePath = ansysExePath;
            this.scriptPath = scriptPath;
            this.ansysProjectPath = ansysProjectPath;
            this.xmlWorker = XmlWorker(fullfile(PROPERTIES.mainXmlPath, PROPERTIES.mainXmlName));
            this.matlabCommandPath = char(this.xmlWorker.getValueOf('matlab-cmd')); %strcat(PROPERTIES.workDirectoryPath, '\listenme\matlab_command.txt');
            this.ansysCommandPath = char(this.xmlWorker.getValueOf('ansys-cmd'));%strcat(PROPERTIES.workDirectoryPath, '\listenme\ansys_command.txt');
        end
        function run(this)    
            command = this.buildRunCommand();     
            
            Logger.info(sprintf('ansys run command: %s', command));    
            disp(command);
            
            system(command);                
        end   
        function [targetValue] = update(this, inVector)      
            global PROPERTIES;
            
            if ( PROPERTIES.isTerminate )
                Logger.info('End. You can close Ansys.');
                return;
            end
            
            Logger.info(' ');%separator
            
            % write new parameters to ansys            
            this.xmlWorker.setInputParameters(inVector);                    
            
            % update ansys with new parameters
            updateCommand = strcat('update-', num2str(rand(1, 1)));
            this.setCommand(this.ansysCommandPath, updateCommand);
            
            %reset state. set command as wait
            this.setCommand(this.matlabCommandPath, 'wait');
            
            Logger.info('Call Ansys...');         
            
            % waiting
            time = this.waitWhileAnsysCalculate();           
            
            Logger.info(sprintf('Ansys working %s seconds', num2str(time)));
            
            % return Total Deforamtion, Maximum Combined Stress Maximum and Geometry Mass as criteria of optimization
            [outValues, outNames] = this.xmlWorker.getOutputParameters();             
            log = 'Output parameters from Ansys: ';
            quantity = max(size(outValues));
            for i = 1 : quantity
                log = strcat(log, sprintf(' %s: %s, ', char(outNames(i)), num2str(outValues(i))));
            end
            targetValue = this.getTargetValue(outValues);
            log = strcat(log, sprintf(' targetValue: %s\n', num2str(targetValue)));            
            Logger.info(log);            
        end 
        function targetValue = getTargetValue(this, values)
            quantity = max(size(values));
            targetValue = 1;
            for i = 1 : quantity
                targetValue = targetValue * values(i);
            end
        end
    end
end