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
        Logger.info(sprintf('%d.%d: xCur: %s, yCur: %s, dx: %s\n',globalStepCounter, 0, mat2str(xCur), mat2str(yCur), mat2str(dx)));                    
        dxPrev = dx; %����� ���� �� ����. ����� �����. assa
        for i = 1 : n         
            xNext = xCur;
            for j = 1:n%��� �� i �����������
                xNext(j) = xNext(j) + directions(i,j) * dx(i);
            end
            if(xNext > xmin & xNext < xmax) %�������� ������ ������                           
                yNext = targetFunction(xNext);                
                Logger.info(sprintf('%d.%d: xCur: %s, yCur: %s, dx: %s\n',globalStepCounter, i, mat2str(xCur), mat2str(yCur), mat2str(dx)));                                   
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
        if( abs(yCur - yPrev) <= 0.005) %�������� ���������� ����� �����
            failCount = failCount + 1; 
            if(yCur < yk) %�������� ���������� ��������
                [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%��� 4(7 �����)
                directions = GramN(directions, lambda); %����� �����������
                lambda = zeros(1,n);
                dx = dx0;
                failCount = 0;
            else
                if(failCount >= num)
                    [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%��� 4(7 �����)
                    directions = GramN(directions, lambda);
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
