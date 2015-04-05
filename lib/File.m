classdef File
    %FILE This class implements basic operation of file work
    
    properties (Hidden, SetAccess = private)
        filePath;     
        fileName;
        fullPath;
    end
    
    methods
        function o = File(filePath, fileName)
            o.filePath = filePath;               
            o.fileName = fileName;
            o.fullPath = fullfile(filePath, fileName);
        end              
        function [parameters] = readParameters(o)       
            [fileId, errorMessage] = fopen(o.fullPath, 'r');            
            if(fileId == -1)
                error(['error create file - ', o.fullPath, ', message - ', errorMessage]);                  
            end                 
            parameters = [];
            row = fgets(fileId);
            while ischar(row)
                row = regexprep(row,'\s+','');
%                 row = regexp(row, '([A-Za-z0-9]+)=([\d+:\])', 'match');                
                row = regexp(row, '=', 'split');                 
                disp(['key-', char(row(1)), ', value-', char(row(2))]);
                parameters = [parameters; row];                
                row = fgets(fileId);                
            end
            fclose(fileId);
        end
        function writeParameters(o, parameters)             
            [h, ~] = size(parameters);
            text = fileread(o.fullPath);
            for y = 1 : h
                text = regexprep(text, parameters(y, 1), parameters(y, 2));
            end            
            fileId = fopen(fullfile(o.filePath, 'runnable-script.apdl'), 'w');
            fprintf(fileId, '%s', text);
            fclose(fileId);             
        end
    end    
end

