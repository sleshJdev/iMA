function [error, optimizedVector] = rosenbrok(settings, seed, getNewOutputVector)
% TODO: fix algorithm
addpath('./rosenbrock', '-end');

num = settings.getInt('failsQuantity');
a = settings.getDouble('scaleFactor');
b = settings.getDouble('breakFactor');
threshold = settings.getDouble('threshold');
xmax = Converter.parseJsonArray(settings.getJSONArray('xmax'));
xmin = Converter.parseJsonArray(settings.getJSONArray('xmin'));
dx0 = Converter.parseJsonArray(settings.getJSONArray('dx0'));

globalStepCounter = 0;
failCount = 0;
isEndWhile = 0;
n = max(size(initialInputVector));
directions = zeros(n);
for i = 1:n
    directions(i,i) = 1;
end
lambda = zeros(1,n);
dx = dx0;
xCur = initialInputVector;
yCur = getNewOutputVector(initialInputVector);
xk = initialInputVector;
yk = yCur;
while isEndWhile == 0
    globalStepCounter = globalStepCounter + 1;
    yPrev = yCur;
    dxPrev = dx;
    for i = 1 : n
        xNext = xCur;
        for j = 1:n
            xNext(j) = xNext(j) + directions(i,j) * dx(i);
        end
        if(xNext > xmin & xNext < xmax)
            yNext = getNewOutputVector(xNext);
            Logger.info(sprintf('%d.%d: Best::: point: %s, value:_%s, Current::: point: %s, value: %s, Step: %s\n',...
                globalStepCounter, i, mat2str(xCur), mat2str(yCur), mat2str(xNext), mat2str(yNext), mat2str(dx)));
            
            fprintf('%d.%d:_Best::: Point: %s,_Value:_%s, Current::: Point: %s, Value: %s, Step: %s\n',...
                globalStepCounter, i, mat2str(xCur), mat2str(yCur), mat2str(xNext), mat2str(yNext), mat2str(dx));
            if(yNext < yCur)
                xCur = xNext;
                yCur = yNext;
                lambda(i) = lambda(i) + dx(i);
                dx(i) = dx(i) * a;
            else
                dx(i) = dx(i) * b;
            end
        else
            dx(i) = dx(i) * b;
        end
    end
    if( abs(yCur - yPrev) <= 0.000005)
        failCount = failCount + 1;
        if(yCur < yk)
            
            log = sprintf('A. Rotate. New Directions: %s', mat2str(directions));
            fprintf('A. Rotate. New Directions: %s', mat2str(directions));
            
            [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);
            directions = GramN(directions, lambda);
            
            log = strcat(log, sprintf('_______Old Directions: %s\n', mat2str(directions)));
            Logger.info(log);
            disp(log);
            
            lambda = zeros(1,n);
            dx = dx0;
            failCount = 0;
        else
            if(failCount >= num)
                [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);
                
                log = sprintf('B. Rotate. New Directions: %s', mat2str(directions));
                fprintf('B. Rotate. New Directions: %s', mat2str(directions));
                
                directions = GramN(directions, lambda);
                
                log = strcat(log, sprintf('_______Old Directions: %s\n', mat2str(directions)));
                Logger.info(log);
                disp(log);
                
                lambda = zeros(1, n);
                dx = dx0;
                failCount = 0;
            else
                if(abs(dxPrev) < threshold)
                    isEndWhile = 1;
                end
            end
        end
    end
end
error = 0;
optimizedVector = [xCur, yCur];
