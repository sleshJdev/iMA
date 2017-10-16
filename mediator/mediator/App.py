import socket
import sys
import os
sys.path.append(os.path.dirname(os.path.realpath(__file__)))

import utils
from mediator import Mediator

class App:
    
    def __init__(self, context):
        logger = utils.create_logger('ima/' + __name__  , context.log_file_path)
        self.context = context
        self.logger = logger       
        self.mediator = Mediator(context)
        self.logger.debug('mediator has been created')   
        
    def start(self):        
        try:
            self.logger.info('running')
            host = socket.gethostname()
            port = 50006
            self.mediator.start(host, port)
        except Exception as e:
            self.logger.error(e)
            self.mediator.stop()
            raise e
    