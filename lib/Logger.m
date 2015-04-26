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
        function log(message)        
            handles = guihandles();             
            content = get(handles.logListbox, 'String');
            content = [content; message];
            set(handles.logListbox, 'String', content);
        end
        function info(message)
            Logger.log(sprintf('INFO %s: %s', datestr(now, 'HH:MM:SS'), message));
        end
        function debug(message)
            Logger.log(sprintf('ERROR %s: %s', datestr(now, 'HH:MM:SS'), message));
        end
    end    
end

