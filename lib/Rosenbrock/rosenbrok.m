function result = rosenbrok( x0, num, a, b, xmax, xmin, threshold, dx0, targetFunction)
    addpath ..\ % to use Logger
    globalStepCounter = 1;
    localStepCounter = 1;       
    
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
    yCur = targetFunction(x0);
    xk = x0; %массив параметров на пред. итерации
    yk = yCur; %знач. функции на пред. итерации   asdsa
    while isEndWhile == 0
        yPrev = targetFunction(xCur); %знач. фун. на пред. серии шагов
        Logger.info(sprintf('%d.%d: xCur: %s, yCur: %s, dx: %s\n',... 
                            globalStepCounter, localStepCounter, mat2str(xCur), mat2str(yCur), mat2str(dx)));
        dxPrev = dx; %длины шага на пред. серии шагов. assa
        for i = 1 : n         
            xNext = xCur;
            for j = 1:n%шаг по i направлению
                xNext(j) = xNext(j) + directions(i,j) * dx(i);
            end
            if(xNext > xmin & xNext < xmax) %проверка границ поиска                           
                yNext = targetFunction(xNext);                
                Logger.info(sprintf('%d.%d: xCur: %s, yCur: %s, dx: %s\n',... 
                            globalStepCounter, localStepCounter, mat2str(xCur), mat2str(yCur), mat2str(dx)));       
                if(yNext < yCur)%проверка успешности шага
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
        end %конец серии шагов
        if( abs(yCur - yPrev) <= 0.005) %проверка успешности серии шагов
            failCount = failCount + 1; 
            if(yCur < yk) %проверка успешности итерации
                [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%шаг 4(7 строк)
                directions = GramN(directions, lambda); %новые направления
                lambda = zeros(1,n);
                dx = dx0;
                failCount = 0;
            else
                if(failCount >= num)
                    [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%шаг 4(7 строк)
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
    result = [ xCur yCur ];
