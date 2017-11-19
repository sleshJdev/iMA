classdef Rosenbrock < handle
    %A Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        terminated = false;
        scaleFactor, breakFactor, maxFails, threshold, intialStepSizes;
        startPoint, initialValue;
        lowerBound, upperBound;
    end
    
    methods
        function self = Rosenbrock(settings, startPoint, initialValue,...
                                   intialStepSizes, lowerBound, upperBound)
            % settings
            self.scaleFactor = settings.getDouble('Scale Factor');
            self.breakFactor = settings.getDouble('Break Factor');
            self.maxFails = settings.getInt('Max Fails');
            self.threshold = settings.getDouble('Threshold');
            
            self.startPoint = startPoint;
            self.initialValue = initialValue;
            
            self.intialStepSizes = intialStepSizes;
            self.lowerBound = lowerBound;
            self.upperBound = upperBound;
        end
        function terminate(self)
            self.terminated = true;
        end
        function [message, optimizedVector, optimizedValue] = start(...
                self, computeNextValue, log)
            numberDimensions = length(self.startPoint);
            % initialization
            stepSizes = self.intialStepSizes;
            directions = diag(ones(numberDimensions, 1));
            dimensionPoints = zeros(numberDimensions, numberDimensions + 1);
            dimensionValues = zeros(1, numberDimensions + 1);
            
            dimensionPoints(:, 1) = self.startPoint;
            iterationPoints(:, 1) = self.startPoint;
            optimizationPath(:, 1) = self.startPoint;
            dimensionValues(1) = self.initialValue;
            iterationValues(1) = self.initialValue;
            optimizationValues(1) = self.initialValue;
            
            iterationsCounter = 1;
            failsCounter = 0;
            while ~self.isTerminated()
                log(['>>> Next round(rotations = ', num2str(iterationsCounter), ')']);
                for dimension = 1 : numberDimensions
                    if self.isTerminated()
                        message = 'CANCELED';
                        optimizedVector = iterationPoints(:, end);
                        optimizedValue = iterationValues(:, end);
                        return;
                    end                    
                    [nextPoint, ~] = self.clamp(...
                        dimensionPoints(:, dimension) + stepSizes(dimension) * directions(:, dimension));    
                    
                    [status, nextValue, newOutputParams] = computeNextValue(nextPoint);
                    if status ~= 200
                        message = 'ERROR';
                        optimizedVector = iterationPoints(:, end);
                        optimizedValue = iterationValues(:, end);
                        return;
                    end
                    if nextValue < dimensionValues(dimension)
                        dimensionPoints(:, dimension + 1) = nextPoint;
                        dimensionValues(dimension + 1) = nextValue;
                        stepSizes(dimension) = stepSizes(dimension) * self.scaleFactor;
                        optimizationPath(:, end + 1) = nextPoint;
                        optimizationValues(end + 1) = nextValue;
                        log(['Successful attept on dimension ', num2str(dimension),...
                            ', next point ', mat2str(nextPoint),...
                            ', out params ', mat2str(newOutputParams),...
                            '(', num2str(nextValue), ')',...
                            ', new step sizes: ', mat2str(stepSizes)]);
                    else
                        dimensionPoints(:, dimension + 1) = dimensionPoints(:, dimension);
                        dimensionValues(dimension + 1) = dimensionValues(dimension);
                        stepSizes(dimension) = stepSizes(dimension) * self.breakFactor;
                        log(['Unsuccessful attept on dimension ',num2str(dimension),...
                            ', current point ', mat2str(dimensionPoints(:, dimension)),...
                            '(', num2str(dimensionValues(dimension)), ')',...
                            ', new step sizes: ', mat2str(stepSizes)]);
                    end
                end
                firstDimensionPoint = dimensionPoints(:, 1);
                firstDimensionValue = dimensionValues(1);
                lastDimensionPoint = dimensionPoints(:, end);
                lastDimensionValue = dimensionValues(end);
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
                            stepSizes = self.intialStepSizes;
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
                                    '. Start next iteration from the point ', mat2str(lastDimensionPoint),...
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
        function [point, clamped] = clamp(self, point)
            clamped = false;
            for i = 1 : length(point)
                if point(i) < self.lowerBound(i)
                    point(i) = self.lowerBound(i);
                    clamped = true;
                end
                if point(i) > self.upperBound(i)
                    point(i) = self.upperBound(i);
                    clamped = true;
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

