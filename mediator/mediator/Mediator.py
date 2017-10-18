import socket
import json
import time

from mediator import utils
from mediator.dispatch import Dispatcher   

class Mediator:   
	
    def __init__(self, context):
        print "1"
        self.logger = utils.create_logger(__name__, context.log_file_path)
        self.context = context
        self.dispatcher = Dispatcher(context)
        self.logger.debug('dispatcher has been created')        

    def accept_request(self, request):                       
        response = self.dispatcher.dispath(request)            
        self.__respond(response)   
    
    def __respond(self, response):
        s = self.__open_socket("localhost", 50001)
        try:
            self.logger.info('response: {!s}'.format(response))
            s.sendall(str(response))
            # s.sendall("<EOF>")
            s.sendall(os.linesep)
        except Exception as e:
            self.__close_socket(s)
            self.logger.error("error during sending response: {!s}. error details: {!s}".format(response, e))           

    def __open_socket(self, host, port):
        self.logger.info('opening a socket to {!s}:{!s}...'.format(host, port))        
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((host, port))
            return s
        except Exception as e:
            self.__close_socket(s)
            logger.error("error during opening a socket to {!s}:{!s}. error details: {!s}".format(host, port, e))
            raise e
            
    def __close_socket(self, s):
        self.logger.info('releasing the resources...')        
        try:
            if s: s.close()
        except Exception as e:
            self.logger.error("error durind closing a socket {!s}".format(s))
            raise e