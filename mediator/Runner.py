import clr
clr.AddReference('System.Windows.Forms')
import System
from System.Collections import *
from System.IO import *
from System import DateTime
from System import TimeSpan
from System.Windows.Forms import MessageBox

import threading
import os
import sys
import time
import json

#work_dir = os.path.dirname(os.path.realpath(__file__))
work_dir = r"C:\Users\User\Documents\MATLAB\iMA\mediator"
log_file_path = os.path.join(work_dir, 'log.log')
sys.path.append(work_dir)

from mediator import utils
from mediator import WBClient

logger = utils.create_logger('ima/System', log_file_path)
class Context:
    def __init__(self):  
        self.logger = logger
        self.work_dir = work_dir
        self.log_file_path = log_file_path
        # ansys services
        self.Parameters = Parameters
        self.UpdateAllDesignPoints = UpdateAllDesignPoints       
            
logger.info('start initializing of iMA Mediator')
ima_awb_client = WBClient(Context())
logger.info("iMA Mediator has was initialized successfully")
    