import sys
import os
sys.path.append(os.path.dirname(os.path.realpath(__file__)))

import socket
import json
import time
import utils
import dispatch
from dispatch import Dispatcher   

class Mediator:   
	
    def __init__(self, context):
        self.logger = logger = utils.create_logger('ima/' + __name__, context.log_file_path)
        self.context = context
        self.dispatcher = Dispatcher(context)
        self.logger.debug('dispatcher has been created')        

    def start(self, host, port):          
        self.__open_socket(host, port)        
        while True:
            request = self.__listen()
            if not request: 
                self.stop()
                break            
            response = self.dispatcher.dispath(request)            
            self.__respond(response)

    def stop(self):
        self.__close_socket()
    
    def __respond(self, response):
        time.sleep(1)
        self.logger.info('response: {!s}'.format(response))
        self.connection.sendall(str(response))
        self.connection.sendall(os.linesep)

    def __listen(self):
        self.logger.info('waiting for request...')
        message = self.connection.recv(20 * 1024)        
        if not message: return None
        request = json.loads(message) 
        self.logger.debug('request: ' + str(request))          
        return request

    def __open_socket(self, host, port):
        self.logger.info('opening a socket...')
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind((host, port))
        s.listen(1)
        connection, address = s.accept()
        self.socket = s
        self.connection = connection
        self.logger.debug('connected by: {!s}'.format(address))
        return address

    def __close_socket(self):
        self.logger.info('releasing the resources...')
        if self.connection:
           self.connection.close() 
        if self.socket:         
            self.socket.shutdown(socket.SHUT_RDWR)
            self.socket.close()