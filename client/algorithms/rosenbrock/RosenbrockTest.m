% clear java;
javaaddpath('..\libraries\orgjson.jar');
addpath('..\');
f = @(v)deal(200, 4*(v(1,:) - 5).^2 + (v(2,:) - 6).^2, v);
startPoint = [8; 9];
[~, initialValue, ~] = f(startPoint);

settings = org.json.JSONObject('{"Scale Factor": 2, "Break Factor": -0.5, "Max Fails": 13, "Threshold": 0.6}');
logger = @(message)disp(message);
algorithms = Algorithms();
algorithm = Rosenbrock(settings, startPoint, initialValue, [1, 2], [-10, -10], [20, 20]);

[message, optimizedVector, optimizedValue] = algorithm.start(f, logger);
disp([message, mat2str(optimizedVector), num2str(optimizedValue)]);