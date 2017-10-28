classdef Rosenbrock < handle
    %A Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        terminated = false;
        scaleFactor, breakFactor, maxFails, threshold;
        lowerBound, upperBound;
    end
    
    methods
        function self = Rosenbrock(settings, lowerBound, upperBound)
            % settings
            self.scaleFactor = settings.getDouble('scaleFactor');
            self.breakFactor = settings.getDouble('breakFactor');
            self.maxFails = settings.getInt('maxFails');
            self.threshold = settings.getDouble('threshold');
            
            self.lowerBound = lowerBound;
            self.upperBound = upperBound;
        end
        function terminate(self)
            self.terminated = true;
        end
        function [message, optimizedVector, optimizedValue] = start(...
                self, startPoint, initialValue, computeNextValue, log)
            numberDimensions = length(startPoint);
            intialStepSizes = 1:1:numberDimensions;
            % initialization
            stepSizes = intialStepSizes;
            directions = diag(ones(numberDimensions, 1));
            dimensionPoints = zeros(numberDimensions, numberDimensions + 1);
            iterationPoints = zeros(numberDimensions, 1);
            optimizationPath = zeros(numberDimensions, 1);
            
            dimensionPoints(:, 1) = startPoint;
            iterationPoints(:, 1) = startPoint;
            optimizationPath(:, 1) = startPoint;
            dimensionValues(1) = initialValue;
            iterationValues(1) = initialValue;
            optimizationValues(1) = initialValue;
            
            iterationsCounter = 1;
            failsCounter = 0;
            while ~self.isTerminated()
                log(['>>> Next round(rotations = ', num2str(iterationsCounter), ')']);
                for dimension = 1 : numberDimensions
                    if self.isTerminated()
                        message = 'CANCELED';
                        optimizedVector = iterationPoints(:, iterationsCounter);
                        optimizedValue = iterationValues(:, iterationsCounter);
                        return;
                    end
                    nextPoint = dimensionPoints(:, dimension) + stepSizes(dimension) * directions(:, dimension);
                    if self.isAbroad(nextPoint)
                        message = 'ABROAD';
                        optimizedVector = iterationPoints(:, iterationsCounter);
                        optimizedValue = iterationValues(:, iterationsCounter);
                        return;
                    end
                    [status, nextValue] = computeNextValue(nextPoint);
                    if status ~= 200
                        message = 'ERROR';
                        optimizedVector = iterationPoints(:, iterationsCounter);
                        optimizedValue = iterationValues(:, iterationsCounter);
                        return;
                    end
                    if nextValue < dimensionValues(dimension)
                        dimensionPoints(:, dimension + 1) = nextPoint;
                        dimensionValues(dimension + 1) = nextValue;
                        stepSizes(dimension) = stepSizes(dimension) * self.scaleFactor;
                        optimizationPath = [optimizationPath, nextPoint];
                        optimizationValues = [optimizationValues, nextValue];
                        log(['Successful attept on dimension ',num2str(dimension),...
                            ', next point ', mat2str(nextPoint),...
                            '(', num2str(nextValue), ')',...
                            ', new steps sizes: ', mat2str(stepSizes)]);
                    else
                        dimensionPoints(:, dimension + 1) = dimensionPoints(:, dimension);
                        dimensionValues(dimension + 1) = dimensionValues(dimension);
                        stepSizes(dimension) = stepSizes(dimension) * self.breakFactor;
                        log(['Unsuccessful attept on dimension ',num2str(dimension),...
                            ', current point ', mat2str(dimensionPoints(:, dimension)),...
                            '(', num2str(dimensionValues(dimension)), ')',...
                            ', new steps sizes: ', mat2str(stepSizes)]);
                    end
                end
                firstDimensionPoint = dimensionPoints(:, 1);
                firstDimensionValue = dimensionValues(1);
                lastDimensionPoint = dimensionPoints(:, numberDimensions + 1);
                lastDimensionValue = dimensionValues(numberDimensions + 1);
                log(['Iteration ', num2str(iterationsCounter), ' was finished'...
                    ', start point is ', mat2str(dimensionPoints(:, 1)), '(', num2str(firstDimensionValue),')',...
                    ', end point is ', mat2str(lastDimensionPoint), '(',num2str(lastDimensionValue),')']);
                if lastDimensionValue < firstDimensionValue
                    dimensionPoints(:, 1) = lastDimensionPoint;
                    dimensionValues(1) = lastDimensionValue;
                    log(['Iteration ', num2str(iterationsCounter), ' was successful. ',...
                        'Starting a new iteration from point: ', mat2str(firstDimensionPoint)]);
                elseif firstDimensionValue == lastDimensionValue
                    lastIterationValue = iterationValues(iterationsCounter);
                    log('All attepts were unsuccessful. Checking successfullness of iteration... ');
                    if lastDimensionValue < lastIterationValue
                        iterationPoints(:, iterationsCounter + 1) = lastDimensionPoint;
                        iterationValues(iterationsCounter + 1) = lastDimensionValue;
                        lastIterationPoint = iterationPoints(:, iterationsCounter + 1);
                        prevIterationPoint = iterationPoints(:, iterationsCounter);
                        offset = dist(transp(lastIterationPoint), prevIterationPoint);
                        if offset <= self.threshold
                            log(['Solution found(offset is less than threshold): ', mat2str(lastDimensionPoint),...
                                ', value: ', num2str(lastDimensionValue)]);
                            break;
                        else
                            log(['The point offset by all dimension is not less than ', num2str(self.threshold),...
                                '. Performing axes rorations']);
                            log(['Current directions: ', mat2str(directions)]);
                            directions = Rosenbrock.gsrotate(lastIterationPoint - prevIterationPoint, directions);
                            stepSizes = intialStepSizes;
                            dimensionPoints(:, 1) = lastIterationPoint;
                            dimensionValues(1) = iterationValues(iterationsCounter + 1);
                            iterationsCounter = iterationsCounter + 1;
                            log(['New directions: ', mat2str(directions),...
                                ', iteration ', num2str(iterationsCounter),...
                                ', steps sizes: ', mat2str(stepSizes),...
                                ', current point: ', mat2str(dimensionPoints(:, 1))]);
                        end
                    elseif lastDimensionValue == lastIterationValue
                        failsCounter = failsCounter + 1;
                        if(failsCounter > self.maxFails)
                            log(['The max number of attepts was achived, found point ', mat2str(iterationPoints(:, iterationsCounter)), ', value: ', num2str(lastIterationValue)]);
                            break;
                        else
                            stepLessThanThreshold = sum(abs(stepSizes) <= self.threshold) == numberDimensions;
                            if stepLessThanThreshold
                                log(['Solution found(steps by all dimensions are less than', self.threshold, '): ', mat2str(iterationPoints(:, iterationsCounter)),...
                                    ', value: ', num2str(lastIterationValue)]);
                                break;
                            else
                                log(['Steps by all dimensions are not less than ', num2str(self.threshold),...
                                    '. Begging next iteration from point ', mat2str(lastDimensionPoint),...
                                    '(',num2str(dimensionValues(numberDimensions + 1)),')']);
                                dimensionPoints(:, 1) = lastDimensionPoint;
                            end
                        end
                    end
                end
            end
            message = 'OK';
            optimizedVector = iterationPoints(:, iterationsCounter);
            optimizedValue = iterationValues(:, iterationsCounter);
        end
    end
    methods(Access = private)
        function terminated = isTerminated(self)
            terminated = self.terminated;
        end
        function abroaded = isAbroad(self, point)
            abroaded = false;
            for i = 1 : length(point)
                if point(i) < self.lowerBound(i) || point(i) > self.upperBound(i)
                    abroaded = true;
                    break;
                end
            end
        end        
    end
    methods(Static)
        function d = gsrotate(delta, basises)
            % Gramm - Shmidt axes rotation algorithm
            %   delta - orientation vector
            %   basises - current directions
            n = length(basises);
            lamdas = basises \ delta;
            a = zeros(n);
            b = zeros(n);
            d = zeros(n);
            for i = 1 : n
                ai = zeros(n, 1);
                for j = i : n
                    ai = ai + lamdas(j) * basises(:, j);
                end
                a(:, i) = ai;
            end
            for i = 1 : n
                if i == 1
                    b(:, 1) = a(:, 1);
                    d(:, 1) = b(:, 1) / dist(transp(b(:, 1)), zeros(n, 1));
                else
                    s = zeros(n, 1);
                    for j = 1 : i - 1
                        s = s + (transp(a(:, i)) * d(:, j)) * d(:, j);
                    end
                    b(:, i) = a(:, i) - s;
                    d(:, i) = b(:, i) / dist(transp(b(:, i)), zeros(n, 1));
                end
            end
        end
    end
end

