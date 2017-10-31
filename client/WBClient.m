classdef WBClient < handle
    %COMMUNICATOR Summary of this class goes here
    %   Detailed explanation goes here
    properties(Access = private)
        ansysHost, ansysPort;
        wbclientHost, wbclientPort;
        wbclientTick, wbclientTimeout,
        wbcAnsysParamPrefix, wbclientVarName;
        mediatorPath, runnerPath, controlPath, requestPath, responsePath;
        terminated = false;
    end
    properties(Constant)
        PACKAGE_SIZE = 20 * 1024 % 20Kb
    end
    
    methods(Access = public)
        function self = WBClient(config)
            wbclientConfig = config.getJSONObject('wbclient');
            self.wbclientVarName = wbclientConfig.getString('varInstanceName');
            self.wbclientHost = wbclientConfig.getString('host');
            self.wbclientPort = wbclientConfig.getInt('port');
            self.wbclientTimeout = wbclientConfig.getInt('timeout');
            self.wbclientTick = wbclientConfig.getInt('tick');    
            self.wbcAnsysParamPrefix = wbclientConfig.getString('ansysParamPrefix');                 
            ansysConfig = config.getJSONObject('ansys');
            self.ansysHost = ansysConfig.getString('host');
            self.ansysPort = ansysConfig.getInt('port');            
            
            self.mediatorPath = [pwd, filesep, 'mediator'];
            self.controlPath = [pwd, filesep, 'control'];
            self.responsePath = [self.controlPath, filesep, 'response'];
            self.requestPath = [self.controlPath, filesep, 'request'];
            self.runnerPath = [self.mediatorPath, filesep, 'Runner.py'];
        end
        function prefix = getAnsysParamPrefix(self)
            prefix = char(self.wbcAnsysParamPrefix);
        end
        function setup(self)      
            writer = 0;
            try 
                template = fileread([pwd, filesep, 'client', filesep, 'resources', filesep, 'Runner.py.template']);
                template = strrep(template, '${MEDIATOR_PATH}', self.mediatorPath);
                template = strrep(template, '${CONTROL_PATH}', self.controlPath);
                runnerCode = strrep(template, '${WBCLIENT_VAR_NAME}', char(self.wbclientVarName));                 
                delete(self.runnerPath); 
                writer = java.io.FileWriter(self.runnerPath);
                writer.write(runnerCode);                   
                writer.close();
                self.sendAndCheck(runnerCode);
            catch e
                Logger.error('Could not generate a Ansys Workbench mediator runner, please check console output for detaisl');
                if writer ~= 0
                    writer.close();
                end
                rethrow(e);
            end            
        end
        function terminate(self)
            self.terminated = true;
        end
        function reset(self)
            self.terminated = false;
            self.cleanResponse();
        end
        function sendOnly(self, message)
            self.send(message, false);
%             self.write(message);
        end
        function sendAndCheck(self, message)
            self.send(message, true);
        end
        function execute(self, command)
            command = sprintf(...
                '%s.execute("""%s""")',...
                char(self.wbclientVarName), char(command));
            self.sendOnly(command);
        end
        function json = waitForResponse(self)
            try
                computationTime = 0;
                while ~self.terminated && ~exist(self.responsePath, 'file') && computationTime < 300 % 5 minutes
                    pause(self.wbclientTick);
                    computationTime = computationTime + self.wbclientTick;
                end
                response = fileread(self.responsePath);
                json = org.json.JSONObject(response);
                self.cleanResponse();
                Logger.info(sprintf(...
                    'Computation time: %ds, Response: %s',...
                    computationTime, char(json.toString())));
            catch e
                Logger.error(e);
                rethrow(e);
            end;
        end
    end
    
    methods(Access = private)
        function write(self, message)
            writer = 0;
            try
                writer = java.io.FileWriter(self.requestPath);
                writer.write(char(message));                   
                writer.close();
            catch e
                Logger.error('Canno write request');
                if writer ~= 0
                    writer.close();
                end
                rethrow(e);
            end            
        end
        function send(self, message, checkIfOk)
            socket = 0; in = 0; out = 0; 
            try
                socket = java.net.Socket(self.ansysHost, self.ansysPort);          
                out =  java.io.PrintStream(java.io.BufferedOutputStream(socket.getOutputStream, 8 * 1024), true);
                out.print(char(message));
                out.print('<EOF>');
                if (checkIfOk)
                    in  = java.io.BufferedReader(java.io.InputStreamReader(socket.getInputStream), self.PACKAGE_SIZE);
                    answer = in.readLine();
                    if strcmp(answer, '<OK>')
                        Logger.info(sprintf(...
                            'Successful Transmission: %s', char(answer)));
                    else
                        Logger.error(sprintf(...
                            'Transmission failed.  Check server reply for details: %s', char(answer)))
                    end
                end
                WBClient.close(socket, in, out);
            catch e
                Logger.error(e);
                WBClient.close(socket, in, out);
            end;
        end
        function error = tryClearResponse(self)
            try
                delete(self.responsePath);
                error = 0;
            catch e
                pause(1);
                error = e;
            end
        end
        function cleanResponse(self)
            if exist(self.responsePath, 'file') == 2
                for i = 1 : 3
                    error = self.tryClearResponse();
                    if ~error, break, end;
                end
            end
        end
    end
    
    methods(Static)
        function close(socket, in, out)
            if ~isequal(in, 0)
                try in.close(), catch e, Logger.error(e), end;
            end
            if ~isequal(out, 0)
                try out.close(), catch e, Logger.error(e), end;
            end
            if ~isequal(socket, 0)
                try socket.close(), catch e, Logger.error(e), end;
            end
        end
    end
end

