function result = rosenbrok( x0, N, a, b, xmax, xmin, threshold, dx0 )
global PROPERTIES;    
        
ansysRunner = AnsysRunner(PROPERTIES.ansysExeFullPath, ...
                          fullfile(PROPERTIES.scriptPath, PROPERTIES.scriptName), ...
                          fullfile(PROPERTIES.ansysProjectPath, PROPERTIES.ansysProjectName));   
                      
k = 0; failCount = 0; isEndWhile = 0;
directions = [1 0 0; 0 1 0; 0 0 1];
lambda = [0 0 0];
dx = dx0; 
xCur = x0;
xk = x0; 
yk = ansysRunner.run(x0);
vy = [xk yk];

% while isEndWhile == 0  
%     yPrev = myFunc(xCur);
%     for i = 1:1:3         
%         xNext = xCur;
%         xNext(1) = xNext(1) + directions(i,1) * dx(i);
%         xNext(2) = xNext(2) + directions(i,2) * dx(i);
%         xNext(3) = xNext(3) + directions(i,3) * dx(i);
%         if((xNext(1) > xmin(1)) && (xNext(2) > xmin(2)) && (xNext(3) > xmin(3)) && (xNext(1) < xmax(1)) && (xNext(2) < xmax(2)) && (xNext(3) < xmax(3)))              
%             yNext = myFunc(xNext);
%             yCur = myFunc(xCur);
%             k = k + 2; %счётчик вызова ansys
%             if(yNext < yCur)
%                 xCur = xNext;
%                 yCur = yNext;
%                 lambda(i) = lambda(i) + dx(i);
%                 dx(i) = dx(i) * a; 
%                 vy = [vy; xCur yCur];
%             else
%                 dx(i) = dx(i) * b;
%             end
%         else
%             dx(i) = dx(i) * b;
%         end
%     end
%     if(yCur == yPrev)
%         failCount = failCount + 1;
%         if(yCur < yk)        
%             if(sqrt((xk(1) - xCur(1))^2 + (xk(2) - xCur(2))^2 + (xk(3) - xCur(3))^2) < threshold)
%                 isEndWhile = 1; 
%             else
%                 xk = xCur;
%                 yk = yCur;
%             end
%             directions = GramSmit(directions, lambda);
%             lambda = [0 0 0];
%             dx = dx0;
%             failCount = 0;
%         else
%             if(failCount >= N)              
%                 if(sqrt((xk(1) - xCur(1))^2 + (xk(2) - xCur(2))^2 + (xk(3) - xCur(3))^2) < threshold)
%                     isEndWhile = 1; 
%                 else
%                     xk = xCur;
%                     yk = yCur;
%                 end
%                 directions = GramSmit(directions, lambda);
%                 lambda = [0 0 0];
%                 dx = dx0;
%                 failCount = 0;
%             else
%                 if(abs(dx) < threshold)
%                     isEndWhile = 1; 
%                 end
%             end  
%         end       
%      end
% end
k
result = vy;
