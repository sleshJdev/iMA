import clr
import System
clr.AddReference('System.Windows.Forms')
from System.Collections import *
from System.IO import *
from System import DateTime
from System import TimeSpan

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
        self.watcher = FileSystemWatcher(self.context.control)
        self.watcher.Changed += self.onRequest        
        self.watcher.EnableRaisingEvents = True
    
    def onRequest(self, sender, e):
        self.logger.debug("on request, sender: {!s}, event: {!s}".format(sender, e))
        if (e.Name == 'request' and 
            (e.ChangeType == WatcherChangeTypes.Created and
             e.ChangeType == WatcherChangeTypes.Changed)):
            with open(e.FullPath, 'r') as requestFile:
                requestJson = requestFile.read()
            self.execute(requestJson)   
        
    def execute(self, jsonRequest):        
        try:
            request = json.loads(jsonRequest);
            self.mediator.accept_request(request)
        except Exception as e:
            self.logger.error(e)
            raise e
    