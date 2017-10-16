classdef FileChooser
    methods (Static)
        function [path] = getDirectory(title)
            [path] = uigetdir(title);
            if ( isequal(path, 0) )
                Logger.info('cancel');
                return;
            else              
                Logger.info(path);
            end            
        end
        function [fileName, filePath] = getFile(filter, title)
            global PROPERTIES;
            
            if ( PROPERTIES.workDirectoryPath )
                [fileName, filePath, ~] = uigetfile(filter, title, PROPERTIES.workDirectoryPath);
            else
                [fileName, filePath, ~] = uigetfile(filter, title);
            end
            if ( isequal(fileName, 0) )
                Logger.info('cancel');
                return;
            else              
                Logger.info(fullfile(filePath, fileName));
            end
        end
    end    
end

