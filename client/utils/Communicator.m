classdef Communicator < handle
    %COMMUNICATOR Summary of this class goes here
    %   Detailed explanation goes here    
    properties(Access = private)
        host, port,
        socket, in, out
    end
    properties(Constant)
        PACKAGE_SIZE = 20 * 1024 % 20Kb
    end
    
    methods(Access = private)
        function response = listen(self)
            response = self.in.readLine();
        end
        function send(self, message)
            try 
                self.out.println(char(message));
                self.out.flush();
            catch e, Logger.error(e) 
            end;
        end
    end
    
    methods(Access = public)
        function self = Communicator(host, port)
            self.host = host;
            self.port = port;
        end
        
        function connect(self)
            import java.net.Socket
            import java.io.*
            import org.json.*
            try
                self.socket = Socket(self.host, self.port);                    
                self.in  = BufferedReader(InputStreamReader(self.socket.getInputStream), self.PACKAGE_SIZE);
                self.out =  PrintStream(BufferedOutputStream(self.socket.getOutputStream));                        
            catch e
                Logger.error(e);
                self.close();
            end
        end
        function response = makeRequest(self, request)            
            self.send(request);
            jsonResponse = self.listen();            
            response = org.json.JSONObject(jsonResponse);
        end        
        function close(self)
            if ~isempty(self.in)
                try self.in.close(), catch e, Logger.error(e), end;
            end
            if ~isempty(self.out)
                try self.out.close(), catch e, Logger.error(e), end;                
            end
            if ~isempty(self.socket)
                try self.socket.close(), catch e, Logger.error(e), end;
            end
        end
    end    
end

