classdef Logger
    %LOGGER Summary of this class goes here
    %   Detailed explanation goes here
    methods (Static)    
        % while not use. 
        % TODO: maybe implemets write log into file
        function [out] = destination(newOut)
            persistent currentOut;
            if ( nargin >= 1 )
                currentOut = newOut;
            end;
            out = currentOut;
        end       
        function clear()
            handles = guihandles();
            content = get(handles.logListbox, 'String');
            set(handles.logListbox, 'String', {});
        end
        function log(message)        
            handles = guihandles();             
            content = get(handles.logListbox, 'String');
            content = [content; message];
            set(handles.logListbox, 'String', content);
        end
        function info(message)
            Logger.log(sprintf('%s INFO : %s', datestr(now, 'HH:MM:SS'), char(message)));
        end
        function debug(message)
            Logger.log(sprintf('%s DEBUG: %s', datestr(now, 'HH:MM:SS'), char(message)));
        end
        function error(error)
            if ischar(error)
                Logger.log(sprintf('%s ERROR: %s', datestr(now, 'HH:MM:SS'), char(error)));
            elseif strfind(error.identifier, 'MATLAB')
                Logger.log(sprintf('%s ERROR: %s', datestr(now, 'HH:MM:SS'), char(error.message)));
            else
                Logger.log(sprintf('%s ERROR: %s', datestr(now, 'HH:MM:SS'), 'Unknown error has occured, please check program output'));
            end            
        end
    end    
end

