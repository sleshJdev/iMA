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
            
            roundCounter = 0;
            failsCounter = 0;
            while ~self.isTerminated()
                roundCounter = roundCounter + 1;
                log(['>>> Round ', num2str(roundCounter)]);
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
                    pointNumber = (roundCounter - 1) * numberDimensions + dimension;
                    oldStepSizes = stepSizes;
                    if nextValue < dimensionValues(dimension)
                        dimensionPoints(:, dimension + 1) = nextPoint;
                        dimensionValues(dimension + 1) = nextValue;
                        stepSizes(dimension) = stepSizes(dimension) * self.scaleFactor;
                        optimizationPath(:, end + 1) = nextPoint;
                        optimizationValues(end + 1) = nextValue;
                        log(['Successful step from ', mat2str(nextPoint),...
                            '(', num2str(nextValue), ')',...    
                            ' on dimension ', num2str(dimension),...     
                            ', point number ', num2str(pointNumber),...
                            ', out params ', mat2str(newOutputParams),...                            
                            ', step sizes: ', mat2str(oldStepSizes), '->', mat2str(stepSizes)]);
                    else
                        dimensionPoints(:, dimension + 1) = dimensionPoints(:, dimension);
                        dimensionValues(dimension + 1) = dimensionValues(dimension);
                        stepSizes(dimension) = stepSizes(dimension) * self.breakFactor;
                        log(['Unsuccessful step from ', mat2str(nextPoint),... 
                            '(', num2str(nextValue), ')',...
                            ' on dimension ',num2str(dimension),...
                            ', point number ', num2str(pointNumber),...
                            ', out params ', mat2str(newOutputParams),... 
                            ', stay in ', mat2str(dimensionPoints(:, dimension)),...
                            '(', num2str(dimensionValues(dimension)), ')'...
                            ', step sizes: ', mat2str(oldStepSizes), '->', mat2str(stepSizes)]);
                    end
                end
                if dimensionValues(end) < dimensionValues(1)                    
                    log(['Round was successfull'...
                        ', start point is ', mat2str(dimensionPoints(:, 1)), '(', num2str(dimensionValues(1)),')',...
                        ', end point is ', mat2str(dimensionPoints(:, end)), '(',num2str(dimensionValues(end)),')']);
                    failsCounter = 0;
                    dimensionPoints(:, 1) = dimensionPoints(:, end);
                    dimensionValues(1) = dimensionValues(end);
                elseif dimensionValues(end) == dimensionValues(1)
                    failsCounter = failsCounter + 1;
                    log('All attepts were unsuccessful. Checking successfullness of round... ');
                    if dimensionValues(end) == iterationValues(end)
                        if(failsCounter > self.maxFails)
                            log(['The max number of attepts was achived, found point ',...
                                mat2str(iterationPoints(:, end)), ', value: ', num2str(iterationValues(end))]);
                            break;
                        elseif sum(abs(stepSizes) <= self.threshold) == numberDimensions % is step less than threshold
                            log(['Solution found(steps by all dimensions are less than', self.threshold, '): ',...
                                mat2str(iterationPoints(end)), ', value: ', num2str(iterationValues(:, end))]);
                            break;
                        end
                        dimensionPoints(:, 1) = dimensionPoints(:, end);
                        dimensionValues(1) = dimensionValues(end);
                        log('Start next raund');
                    elseif dimensionValues(end) < iterationValues(end)
                        iterationPoints(:, end + 1) = dimensionPoints(:, end);
                        iterationValues(end + 1) = dimensionValues(end);
                        offset = dist(transp(iterationPoints(:, end)), iterationPoints(:, end - 1));
                        if offset <= self.threshold
                            log(['Solution found(offset is less than threshold): ', mat2str(iterationPoints(:, end)),...
                                ', value: ', num2str(iterationValues(end))]);
                            break;
                        else
                            log(['The point offset by all dimension is not less than ', num2str(self.threshold),...
                                '. Performing axes rorations. Current directions: ', mat2str(directions)]);
                            directions = Rosenbrock.gsrotate(...
                                iterationPoints(:, end) - iterationPoints(:, end - 1), directions);
                            stepSizes = self.intialStepSizes;
                            dimensionPoints(:, 1) = iterationPoints(:, end);
                            dimensionValues(1) = iterationValues(end);
                            log(['New directions: ', mat2str(directions),...
                                ', steps sizes: ', mat2str(stepSizes),...
                                ', current point: ', mat2str(dimensionPoints(:, 1))]);
                        end
                    end
                end
            end
            message = 'OK';
            optimizedVector = iterationPoints(:, end);
            optimizedValue = iterationValues(:, end);
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
                if lamdas(i) == 0
                    a(:, i) = basises(:, i);
                else 
                    ai = zeros(n, 1);
                    for j = i : n
                        ai = ai + lamdas(j) * basises(:, j);
                    end
                    a(:, i) = ai;
                end
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

