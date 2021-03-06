from mediator import utils
from mediator import WBClient

class Context:
    def __init__(self, work_dir, control):
        import os
        log_file_path = os.path.join(work_dir, 'log.log')
        self.work_dir = work_dir
        self.control = control
        self.log_file_path = log_file_path
        self.logger = utils.create_logger('mediator.System', log_file_path)       
        self.Parameters = Parameters
        self.UpdateAllDesignPoints = UpdateAllDesignPoints      