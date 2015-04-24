function result = rosenbrok( x0, num, a, b, xmax, xmin, threshold, dx0)
    global ansysRunner

    k = 0; %счётчик Ansys внутри цикла
    failCount = 0; %количество неудачных серий шагов
    isEndWhile = 0; %конец при =1
    [sss1, sss2] = size(x0);
    n = max(sss1, sss2); %кол-во параметров
    directions = zeros(n);
    for i = 1:n %заполнение матрицы направлений
        directions(i,i) = 1;
    end 
    lambda = zeros(1,n); %матрица сум. перемещений по каждому направлению
    dx = dx0; %массив с длинами шага
    xCur = x0; %массив параметров текущий
    yCur = ansysRunner.update(x0);
    xk = x0; %массив параметров на пред. итерации
    yk = yCur; %знач. функции на пред. итерации   asdsa
%     vy = [ xk yk ]; %матрица для вывода на консоль удачных шагов
    disp('before while');
    while isEndWhile == 0
        yPrev = ansysRunner.update(xCur); %знач. фун. на пред. серии шагов
        disp('same ansys');
        dxPrev = dx; %длины шага на пред. серии шагов. assa
        for i = 1 : n         
            xNext = xCur;
            for j = 1:n%шаг по i направлению
                xNext(j) = xNext(j) + directions(i,j) * dx(i);
            end
            if(xNext > xmin & xNext < xmax) %проверка границ поиска           
                yNext = ansysRunner.update(xNext);
                disp('ansys calculate');
                k = k + 2; %счётчик вызова ansys             
                if(yNext < yCur)%проверка успешности шага
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
        end %конец серии шагов
        if( abs(yCur - yPrev) <= 0.005) %проверка успешности серии шагов
            failCount = failCount + 1; 
            if(yCur < yk) %проверка успешности итерации
                [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%шаг 4(7 строк)
%                 disp(vy);
%                 vy = [xk yk];
                directions = GramN(directions, lambda); %новые направления
                lambda = zeros(1,n);
                dx = dx0;
                failCount = 0;
            else
                if(failCount >= num)
                    [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%шаг 4(7 строк)
%                     disp(vy);
%                     vy = [xk yk];
                    directions = GramN(directions, lambda);
                    lambda = zeros(1, n);
                    dx = dx0;
                    failCount = 0;
                else
                    if(abs(dxPrev) < threshold) %проверка окончания
                        isEndWhile = 1;                   
                    end
                end  
            end       
         end
    end
    k
    result = [ xCur yCur ];
