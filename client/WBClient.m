classdef WBClient < handle
    %COMMUNICATOR Summary of this class goes here
    %   Detailed explanation goes here
    properties(Access = private)
        ansysHost, ansysPort;
        wbclientHost, wbclientPort;
        wbclientTick, wbclientTimeout, 
        wbcAnsysParamPrefix, wbclientVarName;
        responsePath;
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
            self.responsePath = sprintf('%s\\mediator\\response', pwd);            
            ansysConfig = config.getJSONObject('ansys');
            self.ansysHost = ansysConfig.getString('host');
            self.ansysPort = ansysConfig.getInt('port');
        end
        function prefix = getAnsysParamPrefix(self)
            prefix = char(self.wbcAnsysParamPrefix);
        end
        function setup(self)
            mediatorPath = sprintf('%s\\mediator', pwd);
            message = sprintf('%s\n%s\n%s\n%s',...
                'import sys',...
                sprintf('sys.path.append("%s")', mediatorPath),...
                fileread(sprintf('%s\\Runner.py', mediatorPath)),...
                sprintf(...
                    '%s = WBClient(Context("%s"))',...
                    char(self.wbclientVarName), mediatorPath));
            self.sendAndCheck(message);
        end
        function reset(self)
            self.terminated = false;
            if exist(self.responsePath, 'file') == 2
                delete(self.responsePath);
            end
        end
        function sendOnly(self, message)
            self.send(message, false);
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
                while ~self.terminated && ~exist(self.responsePath, 'file')
                    pause(self.wbclientTick);
                    computationTime = computationTime + self.wbclientTick;
                end
                response = fileread(self.responsePath);
                json = org.json.JSONObject(response);
                delete(self.responsePath);
                Logger.info(sprintf(...
                    'Computation time: %ds, Response: %s',...
                    computationTime, char(json.toString())));
            catch e
                Logger.error(e);
            end;
        end
    end
    
    methods(Access = private)
        function send(self, message, checkIfOk)
            socket = 0; in = 0; out = 0; 
            try
                socket = java.net.Socket(self.ansysHost, self.ansysPort);                
                out =  java.io.PrintStream(java.io.BufferedOutputStream(socket.getOutputStream), true);
                out.println(char(message));
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

