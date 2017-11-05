
from mediator import utils

class SeedCommad:

    def __init__(self, context):
        self.context = context   
        self.logger = utils.create_logger(__name__, context.log_file_path)
    
    def execute(self, payload):
        self.logger.info('generating seed started...')
        points = self.context.Parameters.GetAllDesignPoints()
        designPoint = points[0]
        backgroundSession = self.context.UpdateAllDesignPoints(
            DesignPoints=[designPoint], 
            Parameters=None, 
            ErrorBehavior="SkipDesignPoint", 
            CannotCompleteBehavior="Stop")
        self.logger.debug('seed design point {!s} has been updated, backgrounds session: {!s}'.format(
            designPoint, backgroundSession))
        return self.__generate_response(designPoint, backgroundSession)
        
    def __generate_response(self, designPoint, backgroundSession):   
        collectParamInfo = lambda param: {
                        'name': param.Name,
                        'value': designPoint.GetParameterValue(Parameter = param).Value
                    }    
        return {                
                    'designPoint': {
                        'name': designPoint.Name,
                        'displayText': designPoint.DisplayText
                    },
                    'in': map(
                        collectParamInfo,
                        filter(
                            lambda param: not param.IsOutput,
                            self.context.Parameters.GetAllParameters()
                        )
                    ),
                    'out': map(
                        collectParamInfo,
                        filter(
                            lambda param: param.IsOutput,
                            self.context.Parameters.GetAllParameters()
                        )
                    )
                }