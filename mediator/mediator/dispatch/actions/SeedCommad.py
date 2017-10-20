
from mediator import utils

class SeedCommad:

    def __init__(self, context):
        self.context = context   
        self.logger = utils.create_logger('ima/' + __name__, context.log_file_path)
        
    def execute(self, payload):
        self.logger.info('generating seed started...')
        points = self.context.Parameters.GetAllDesignPoints()
        backgroundSession = self.context.UpdateAllDesignPoints(
            DesignPoints=[points[0]], 
            Parameters=None, 
            ErrorBehavior="SkipDesignPoint", 
            CannotCompleteBehavior="Stop")
        self.logger.debug('seed design point {!s} has been updated, backgrounds session: {!s}'.format(
            designPoint, backgroundSession))
        return self.__generate_response(designPoint, backgroundSession)
        
    def __generate_response(self, designPoint, backgroundSession):    
        return {                
                    'designPoint': {
                        'name': designPoint.Name,
                        'displayText': designPoint.DisplayText
                    },
                    'parameters': map(
                        lambda param: {
                            'name': param.Name,
                            'displayText': param.DisplayText,
                            'expression': param.Expression,
                            'value': designPoint.GetParameterValue(Parameter = param).Value,
                            'unit': designPoint.GetParameterValue(Parameter = param).Unit,
                            'minValue': designPoint.GetParameterValue(Parameter = param).MinValue.Value,
                            'maxValue': designPoint.GetParameterValue(Parameter = param).MaxValue.Value
                        },
                        filter(
                            lambda param: param.IsOutput,
                            self.context.Parameters.GetAllParameters()
                        )
                    )
                }