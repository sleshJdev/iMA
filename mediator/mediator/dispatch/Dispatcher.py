import sys
import os
sys.path.append(os.path.dirname(os.path.realpath(__file__)))

import utils
import actions
from actions import CreateDesignPointCommand

class Dispatcher:

    def __init__(self, context):
        self.logger = utils.create_logger('ima/' + __name__, context.log_file_path)
        self.context = context        
        self.create_design_point_command = CreateDesignPointCommand(context)
    
    def dispath(self, request):        
        command = request['command']
        payload = request['payload']
        self.logger.info('dispatch command: {!s}, payload: {!s}'.format(
            command, payload))
        if command == "create-design-point":
            response = self.create_design_point_command.execute(payload)
        elif command == "update":
            response = Update()
        return response