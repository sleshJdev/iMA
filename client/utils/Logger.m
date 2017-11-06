classdef Logger < handle
    %LOGGER Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)
        formatter = SingleLineFormatter();
        handlers = Logger.createFileHandler()
        fileLogger = Logger.createFileLogger(Logger.handlers)
    end
    methods (Static)
        function handlers = createFileHandler()
            logFilePath = [pwd, filesep, 'client', filesep, [datestr(now, 'yyyy-mm-dd'), '.log']];
            fileHandler = java.util.logging.FileHandler(logFilePath, true);
            fileHandler.setFormatter(Logger.formatter);
            handlers = [fileHandler];
        end
        function logger = createFileLogger(handlers)
            logger = java.util.logging.Logger.getLogger('ima-client');
            logger.setUseParentHandlers(false);
            for i = 1 : length(handlers)
                logger.addHandler(handlers(i));
            end
        end
        function close()
            for i = 1 : length(Logger.handlers)
                try
                    Logger.handlers(i).flush();
                    Logger.handlers(i).close();
                catch e
                    disp(e);
                end
            end
        end        
        function clear()
            handles = guihandles();
            set(handles.logListbox, 'String', {''});
        end
        function log(message)
            handles = guihandles();
            content = get(handles.logListbox, 'String');
            if isempty(content)
                content = {''};
            end
            content = [content; message];
            set(handles.logListbox, 'String', content);
            disp(message);
        end
        function info(message)
            Logger.log(sprintf('%s INFO : %s', datestr(now, 'HH:MM:SS'), char(message)));
            Logger.fileLogger.info(char(message));
        end
        function debug(message)
            Logger.log(sprintf('%s DEBUG: %s', datestr(now, 'HH:MM:SS'), char(message)));
            Logger.fileLogger.log(java.util.logging.Level.WARNING, char(message));
        end
        function error(error)
            message = 'Unknown error has occured, please check program output';
            if ischar(error)
                message = char(error);
            elseif strfind(error.identifier, 'MATLAB')
                message = char(error.message);
            end
            Logger.fileLogger.log(java.util.logging.Level.SEVERE, message);
            Logger.log(sprintf('%s ERROR: %s', datestr(now, 'HH:MM:SS'), message));
        end
    end
end

