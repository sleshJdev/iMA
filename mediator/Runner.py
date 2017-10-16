import clr
clr.AddReference('System.Windows.Forms')
import System
from System.Collections import *
from System.IO import *
from System import DateTime
from System import TimeSpan

import threading
import os
import sys
import time
import json

work_dir = os.path.dirname(os.path.realpath(__file__))
log_file_path = os.path.join(work_dir, 'log.log')
sys.path.append(work_dir)

import mediator
from mediator import utils
from mediator import App

logger = utils.create_logger('ima/System', log_file_path)

class Context:
    def __init__(self):  
        self.logger = logger
        self.work_dir = work_dir
        self.log_file_path = log_file_path
        # ansys services
        self.Parameters = Parameters
        self.UpdateAllDesignPoints = UpdateAllDesignPoints       
    
def run():  
    try:        
        app = App(Context())
        logger.debug('app has been created, thread name {!s}'.format(
            threading.currentThread().getName()))
        app.start()
    except Exception as e:
        logger.error(e)
    
if __name__ == "__main__":    
    logger.debug('starting app in separate thread')
    logger.debug('current thread name {!s}'.format(
        threading.currentThread().getName()))
    t = threading.Thread(name = 'App', target = run)
    t.setDaemon(True)
    t.start()
    logger.debug('app thread has started')
    