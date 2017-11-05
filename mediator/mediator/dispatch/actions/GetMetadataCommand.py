from mediator import utils

class GetMetadataCommand:

    def __init__(self, context):
        self.context = context   
        self.logger = utils.create_logger(__name__, context.log_file_path)
        
    def execute(self, payload):
        return self.__generate_response();
    
    def __generate_response(self):   
        collectParamInfo = lambda param: {
                        'name': param.Name,
                        'displayText': param.DisplayText,
                        'expression': param.Expression,                        
                        'unit': param.Value.Unit,
                        'minValue': param.Value.MinValue.Value,
                        'maxValue': param.Value.MaxValue.Value
                    }    
        return {                
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