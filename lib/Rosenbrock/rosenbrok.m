function [resultX, resultY] = rosenbrok( x0, num, a, b, xmax, xmin, threshold, dx0, targetFunction)
    addpath ..\ % to use Logger
    globalStepCounter = 0;     
    
    failCount = 0; %���������� ��������� ����� �����
    isEndWhile = 0; %����� ��� =1    
    n = max(size(x0)); %���-�� ����������
    directions = zeros(n);
    for i = 1:n %���������� ������� �����������
        directions(i,i) = 1;
    end 
    lambda = zeros(1,n); %������� ���. ����������� �� ������� �����������
    dx = dx0; %������ � ������� ����
    xCur = x0; %������ ���������� �������
    yCur = targetFunction(x0);
    xk = x0; %������ ���������� �� ����. ��������
    yk = yCur; %����. ������� �� ����. ��������   asdsa
    while isEndWhile == 0
        globalStepCounter = globalStepCounter + 1;
        yPrev = targetFunction(xCur); %����. ���. �� ����. ����� �����         
        dxPrev = dx; %����� ���� �� ����. ����� �����. assa
        for i = 1 : n         
            xNext = xCur;
            for j = 1:n%��� �� i �����������
                xNext(j) = xNext(j) + directions(i,j) * dx(i);
            end
            if(xNext > xmin & xNext < xmax) %�������� ������ ������                           
                yNext = targetFunction(xNext);                
                Logger.info(sprintf('%d.%d:_Best:::_____Point:_%s,_Value:_%s,_______Current:::__Point:_%s,_Value:_%s, Step:_%s\n',...
                            globalStepCounter, i, mat2str(xCur), mat2str(yCur), mat2str(xNext), mat2str(yNext), mat2str(dx)));
                
                fprintf('%d.%d:_Best:::_____Point:_%s,_Value:_%s', globalStepCounter, i, mat2str(xCur), mat2str(yCur));
                fprintf('_______Current:::__Point:_%s,_Value:_%s, Step:_%s\n', mat2str(xNext), mat2str(yNext), mat2str(dx));    
                if(yNext < yCur)%�������� ���������� ����
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
        end %����� ����� �����
        if( abs(yCur - yPrev) <= 0.000005) %�������� ���������� ����� �����
            failCount = failCount + 1; 
            if(yCur < yk) %�������� ���������� ��������
        
                log = sprintf('A. Rotate. New Directions: %s', mat2str(directions));
                fprintf('A. Rotate. New Directions: %s', mat2str(directions));
                
                [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%��� 4(7 �����)
                directions = GramN(directions, lambda); %����� �����������
                
                log = strcat(log, sprintf('_______Old Directions: %s\n', mat2str(directions)));
                Logger.info(log);
                disp(log);
                
                lambda = zeros(1,n);
                dx = dx0;
                failCount = 0;
            else
                if(failCount >= num)
                    [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%��� 4(7 �����)
                    
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
                    if(abs(dxPrev) < threshold) %�������� ���������
                        isEndWhile = 1;                   
                    end
                end  
            end       
         end
    end
    resultX = xCur;
    resultY = yCur;
