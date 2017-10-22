import io
import os
import socket
import json
import time

from mediator import utils
from mediator.dispatch import Dispatcher   

class Mediator:   
	
    def __init__(self, context):
        self.logger = utils.create_logger(__name__, context.log_file_path)
        self.context = context
        self.dispatcher = Dispatcher(context)
        self.logger.debug('dispatcher has been created')        
    
    def accept_request(self, request):     
        self.logger.debug('request: {!s}'.format(request))
        try:
            payload = self.dispatcher.dispath(request)           
            self.__respondToFile({
                'status': 200,
                'message': 'OK',	
                'payload': payload
            })
        except Exception as e:
            self.__respondToFile({
                'status': 400,
                'message': 'Error during creating a new design point. Details: {!s}'.format(str(e)),
                'payload': {
                    'request': request
                }                
            })
    
    def __respondToFile(self, response):
        self.logger.debug('response: {!s}'.format(response))
        try:
            with io.open(os.path.join(self.context.work_dir, 'response'), 'w', encoding='utf-8') as output:
                #  sort_keys = True, indent = 4, separators = (',', ': '), ensure_ascii = False
                output.write(json.dumps(response))
        except Exception as e:
            self.logger.error("error during sending response: {!s}. error details: {!s}".format(response, e))           
            raise e
 
    def __respond(self, response):
        s = self.__open_socket("localhost", 50001)
        try:
            jsonText = json.dumps(response) 
            self.logger.info('response: {!s}'.format(jsonText))
            s.sendall(jsonText)
            s.sendall(os.linesep)
        except Exception as e:
            self.__close_socket(s)
            self.logger.error("error during sending response: {!s}. error details: {!s}".format(response, e))           
            raise e
    
    def __open_socket(self, host, port):
        self.logger.info('opening a socket to {!s}:{!s}...'.format(host, port))        
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((host, port))
            return s
        except Exception as e:
            self.__close_socket(s)
            self.logger.error("error during opening a socket to {!s}:{!s}. error details: {!s}".format(host, port, e))
            raise e
            
    def __close_socket(self, s):
        self.logger.info('releasing the resources...')        
        try:
            if s: s.close()
        except Exception as e:
            self.logger.error("error durind closing a socket {!s}".format(s))
            raise e