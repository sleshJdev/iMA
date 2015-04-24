function [ isEndWhile, xk, yk ] = checkEnd( xk, yk, xCur, yCur, threshold )
    [sss1, sss2] = size(xk);
    n = max(sss1, sss2);
    dist = 0;
    for i = 1:n
        dist = dist + (xk(i) - xCur(i))^2;
    end
    if(sqrt(dist) < threshold)
        isEndWhile = 1; 
    else
        xk = xCur;
        yk = yCur;
        isEndWhile = 0;
    end
end

