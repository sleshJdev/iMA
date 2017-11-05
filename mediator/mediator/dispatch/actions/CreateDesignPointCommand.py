import json
from mediator import utils

class CreateDesignPointCommand:

    def __init__(self, context):
        self.context = context   
        self.logger = utils.create_logger(__name__, context.log_file_path)
    
    def execute(self, payload):
        designPoint = self.context.Parameters.CreateDesignPoint()
        designPoint.Note = 'generated by iMA'
        designPoint.Retained = False
        params = payload['parameters']
        self.logger.debug('configuring a new designPoint: {!s}'.format(designPoint))
        for param in params:
            name = param['name']
            value = param['value']
            ansysParam = self.context.Parameters.GetParameter(Name=name)
            
            self.logger.debug('parameter: {!s}({!s}), value: {!s}'.format(
                ansysParam.DisplayText, ansysParam.Name, value))
            
            designPoint.SetParameterExpression(
                Parameter=ansysParam, 
                Expression=str(value))
        
        self.logger.debug('updating design point: {!s}...'.format(designPoint))
        backgroundSession = self.context.UpdateAllDesignPoints(
            DesignPoints=[designPoint], 
            Parameters=None, 
            ErrorBehavior="SkipDesignPoint", 
            CannotCompleteBehavior="Stop")
        self.logger.debug('design point {!s} has been updated, backgrounds session: {!s}'.format(
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
                            'value': designPoint.GetParameterValue(Parameter = param).Value
                        },
                        filter(
                            lambda param: param.IsOutput,
                            self.context.Parameters.GetAllParameters()
                        )
                    )
                }