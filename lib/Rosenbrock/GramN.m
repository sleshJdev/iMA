function res = GramN( d, lambda )
    n = size(d);
    n = n(1);
    a = zeros(n);
    for i = 1:n %вычисляется матрица а
        if(lambda(i) == 0)
            for j = 1:n
                a(i,j) = d(i,j);
            end
        else
            for j = i:n
                for k = 1:n
                    a(i,k) = a(i,k) + lambda(j) * d(j,k);
                end
            end
        end
    end
    b = a;
    for i = 1:n
        if(i == 1)
            lenB = 0;
            for j = 1:n
                lenB = lenB + b(i,j)^2;
            end
            lenB = sqrt(lenB);
            for j = 1:n
                d(i,j) = b(i,j) / lenB;
            end
        else
            for j = 1:i-1 
                koef = 0;
                for k = 1:n
                    koef = koef + a(i,k) * d(j,k);
                end
                for k = 1:n
                    b(i,k) = b(i,k) - koef * d(j,k);
                end
            end
            lenB = 0;
            for j = 1:n
                lenB = lenB + b(i,j)^2;
            end
            lenB = sqrt(lenB);
            for j = 1:n
                d(i,j) = b(i,j) / lenB;
            end
        end
    end         
    a
    b
    d
    lambda
    res = d;
end


