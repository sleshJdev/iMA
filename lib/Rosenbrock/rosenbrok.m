function result = rosenbrok( x0, num, a, b, xmax, xmin, threshold, dx0)
    global ansysRunner

    k = 0; %������� Ansys ������ �����
    failCount = 0; %���������� ��������� ����� �����
    isEndWhile = 0; %����� ��� =1
    [sss1, sss2] = size(x0);
    n = max(sss1, sss2); %���-�� ����������
    directions = zeros(n);
    for i = 1:n %���������� ������� �����������
        directions(i,i) = 1;
    end 
    lambda = zeros(1,n); %������� ���. ����������� �� ������� �����������
    dx = dx0; %������ � ������� ����
    xCur = x0; %������ ���������� �������
    yCur = ansysRunner.update(x0);
    xk = x0; %������ ���������� �� ����. ��������
    yk = yCur; %����. ������� �� ����. ��������   asdsa
%     vy = [ xk yk ]; %������� ��� ������ �� ������� ������� �����
    disp('before while');
    while isEndWhile == 0
        yPrev = ansysRunner.update(xCur); %����. ���. �� ����. ����� �����
        disp('same ansys');
        dxPrev = dx; %����� ���� �� ����. ����� �����. assa
        for i = 1 : n         
            xNext = xCur;
            for j = 1:n%��� �� i �����������
                xNext(j) = xNext(j) + directions(i,j) * dx(i);
            end
            if(xNext > xmin & xNext < xmax) %�������� ������ ������           
                yNext = ansysRunner.update(xNext);
                disp('ansys calculate');
                k = k + 2; %������� ������ ansys             
                if(yNext < yCur)%�������� ���������� ����
                    xCur = xNext;
                    yCur = yNext;
                    lambda(i) = lambda(i) + dx(i);
                    dx(i) = dx(i) * a; 
%                     vy = [vy; xCur yCur];
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
%                 disp(vy);
%                 vy = [xk yk];
                directions = GramN(directions, lambda); %����� �����������
                lambda = zeros(1,n);
                dx = dx0;
                failCount = 0;
            else
                if(failCount >= num)
                    [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%��� 4(7 �����)
%                     disp(vy);
%                     vy = [xk yk];
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
    k
    result = [ xCur yCur ];
