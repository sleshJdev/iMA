from mediator import utils
from mediator.dispatch import actions

from actions import CreateDesignPointCommand
from actions import SeedCommad

class Dispatcher:

    def __init__(self, context):
        self.logger = utils.create_logger(__name__, context.log_file_path)
        self.context = context        
        self.seed_command = SeedCommad(context)
        self.create_design_point_command = CreateDesignPointCommand(context)
    
    def dispath(self, request):        
        command = request['command']
        payload = request['payload']
        self.logger.info('dispatch command: {!s}, payload: {!s}'.format(
            command, payload))
        if command == "seed":
            response = self.seed_command.execute(payload)
        elif command == "create-design-point":
            response = self.create_design_point_command.execute(payload)
        elif command == "update":
            response = Update()
        return response