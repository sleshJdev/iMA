import json
from mediator import utils
from mediator import Mediator

class WBClient:
    
    def __init__(self, context):        
        self.context = context
        self.logger = utils.create_logger(__name__  , context.log_file_path)
        self.logger.info('start initializing of iMA Mediator')        
        self.mediator = Mediator(context)
        self.logger.info("iMA Mediator has was initialized successfully") 
    
    def execute(self, jsonRequest):        
        try:
            request = json.loads(jsonRequest);
            self.mediator.accept_request(request)
        except Exception as e:
            self.logger.error(e)
            raise e
    