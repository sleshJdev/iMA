function [resultX, resultY] = rosenbrok( x0, num, a, b, xmax, xmin, threshold, dx0, targetFunction)
    addpath ..\ % to use Logger
    globalStepCounter = 0;     
    
    failCount = 0; %количество неудачных серий шагов
    isEndWhile = 0; %конец при =1    
    n = max(size(x0)); %кол-во параметров
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
        globalStepCounter = globalStepCounter + 1;
        yPrev = targetFunction(xCur); %знач. фун. на пред. серии шагов         
        dxPrev = dx; %длины шага на пред. серии шагов. assa
        for i = 1 : n         
            xNext = xCur;
            for j = 1:n%шаг по i направлению
                xNext(j) = xNext(j) + directions(i,j) * dx(i);
            end
            if(xNext > xmin & xNext < xmax) %проверка границ поиска                           
                yNext = targetFunction(xNext);                
                Logger.info(sprintf('%d.%d:_Best:::_____Point:_%s,_Value:_%s,_______Current:::__Point:_%s,_Value:_%s, Step:_%s\n',...
                            globalStepCounter, i, mat2str(xCur), mat2str(yCur), mat2str(xNext), mat2str(yNext), mat2str(dx)));
                
                fprintf('%d.%d:_Best:::_____Point:_%s,_Value:_%s', globalStepCounter, i, mat2str(xCur), mat2str(yCur));
                fprintf('_______Current:::__Point:_%s,_Value:_%s, Step:_%s\n', mat2str(xNext), mat2str(yNext), mat2str(dx));    
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
        if( abs(yCur - yPrev) <= 0.000005) %проверка успешности серии шагов
            failCount = failCount + 1; 
            if(yCur < yk) %проверка успешности итерации
        
                log = sprintf('A. Rotate. New Directions: %s', mat2str(directions));
                fprintf('A. Rotate. New Directions: %s', mat2str(directions));
                
                [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%шаг 4(7 строк)
                directions = GramN(directions, lambda); %новые направления
                
                log = strcat(log, sprintf('_______Old Directions: %s\n', mat2str(directions)));
                Logger.info(log);
                disp(log);
                
                lambda = zeros(1,n);
                dx = dx0;
                failCount = 0;
            else
                if(failCount >= num)
                    [ isEndWhile, xk, yk ] = checkEnd(xk, yk, xCur, yCur, threshold);%шаг 4(7 строк)
                    
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
                    if(abs(dxPrev) < threshold) %проверка окончания
                        isEndWhile = 1;                   
                    end
                end  
            end       
         end
    end
    resultX = xCur;
    resultY = yCur;
