% clear java;
javaaddpath('..\libraries\orgjson.jar');
addpath('..\');
f = @(v)deal(200, 4*(v(1,:) - 5).^2 + (v(2,:) - 6).^2);
startPoint = [8; 9];
[~, initialValue] = f(startPoint);
algorithmName = 'rosenbrock';
seedPayload = org.json.JSONObject(...
    sprintf('{"in":[{"name": "P4", "value": %d, minValue: -20, maxValue: 10}, {"name": "P3", "value": %d, minValue: -20, maxValue: 10}]}',...
    startPoint(1), startPoint(2)));

settings = org.json.JSONObject('{"algorithms": { "rosenbrock": {"className": "Rosenbrock", "settings": {"scaleFactor": 2, "breakFactor": -0.5, "maxFails": 13, "threshold": 0.6, "stepSizes": [2, 1]}}}}');
logger = @(message)disp(message);
algorithm = AlgoFactory.createAlgorithm(...
    settings.getJSONObject('algorithms').getJSONObject(algorithmName),...
    seedPayload.getJSONArray('in'), initialValue);

[message, optimizedVector, optimizedValue] = self.algorithm.start(f, logger);
disp([message, mat2str(optimizedVector), num2str(optimizedValue)]);