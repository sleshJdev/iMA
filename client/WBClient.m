classdef WBClient < handle
    %COMMUNICATOR Summary of this class goes here
    %   Detailed explanation goes here
    properties(Access = private)
        ansysHost, ansysPort;
        wbclientHost, wbclientPort;
        wbclientTimeout, wbclientVarName;
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
            
            ansysConfig = config.getJSONObject('ansys');
            self.ansysHost = ansysConfig.getString('host');
            self.ansysPort = ansysConfig.getInt('port');
        end
        function setup(self)
            try
                socket = java.net.Socket(self.ansysHost, self.ansysPort);
                in  = java.io.BufferedReader(java.io.InputStreamReader(socket.getInputStream()), self.PACKAGE_SIZE);
                out =  java.io.PrintStream(java.io.BufferedOutputStream(socket.getOutputStream(), true));
                mediatorPath = sprintf('%s\\mediator', pwd);                
                out.println('import sys');                
                out.println(sprintf('sys.path.append("%s")', mediatorPath));
                out.println(fileread(sprintf('%s\\Runner.py', mediatorPath)));
                out.println(sprintf('%s = WBClient(Context("%s"))', char(self.wbclientVarName), mediatorPath));
                out.print('<EOF>');
                answer = in.readLine();
                if strcmp(answer, '<OK>')
                    Logger.debug('Successful Transmission.');
                else
                    Logger.debug('Transmission failed.  Check server reply for details.');
                end
                WBClient.close(socket, in, out, 0);
            catch e
                Logger.error(e);
                WBClient.close(socket, in, out, 0);
            end;
        end
        function command(self, command)
            self.send(command);
        end
        function response = makeRequest(self, request)
            self.send(request);
            jsonResponse = self.listen();
            response = org.json.JSONObject(jsonResponse);
        end
    end
    
    methods(Static)
        function close(socket, in, out, server)
            if ~isempty(in)
                try in.close(), catch e, Logger.error(''), end;
            end
            if ~isempty(out)
                try out.close(), catch e, Logger.error(''), end;
            end
            if ~isempty(socket)
                try socket.close(), catch e, Logger.error(''), end;
            end
            if ~isequal(server, 0)
                try server.close(), catch e, Logger.error(''), end;
            end
        end
    end
    
    methods(Access = private)        
        function send(self, message)
            try
                socket = java.net.Socket(self.ansysHost, self.ansysPort);
                in  = java.io.BufferedReader(java.io.InputStreamReader(socket.getInputStream), self.PACKAGE_SIZE);
                out =  java.io.PrintStream(java.io.BufferedOutputStream(socket.getOutputStream));
                out.println(char(message));
                out.println('<EOF>');
                out.flush();
                answer = in.readLine();
                if isequal(answer, '<OK>')
                    Logger.debug('Successful Transmission.');
                else
                    Logger.error(strcat('Transmission failed.  Check server reply for details: ', char(answer)))
                end
                WBClient.close(socket, in, out);
            catch e
                Logger.error(char(e.message));
                WBClient.close(socket, in, out, 0);
            end;
        end
        function response = listen(self)
            try
                server = java.net.ServerSocket(self.wbclientPort);
                server.setSoTimeout(self.wbclientTimeout * 1000);
                socket = server.accept();
                in  = java.io.BufferedReader(java.io.InputStreamReader(socket.getInputStream), self.PACKAGE_SIZE);
                response = in.readLine();
                WBClient.close(socket, in, 0, server);                
            catch e                
                Logger.error(e);
                WBClient.close(socket, in, 0, server);
            end;
        end
    end
end

