import json
from mediator import utils
from mediator import Mediator

class WBClient:
    
    def __init__(self, context):
        print __name__
        logger = utils.create_logger('ima/' + __name__  , context.log_file_path)
        self.context = context
        self.logger = logger       
        self.mediator = Mediator(context)
        self.logger.debug('mediator has been created')   
        
    def execute(self, jsonRequest):        
        try:
            request = json.loads(jsonRequest);
            self.mediator.accept_request(request)
        except Exception as e:
            self.logger.error(e)
            raise e
    