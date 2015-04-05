function res = GramSmit( d,lambda )
a=[0 0 0;0 0 0;0 0 0];
for i=1:1:3
    if(lambda(i)==0)
        a(i,1)=d(i,1);
        a(i,2)=d(i,2);
        a(i,3)=d(i,3);
    else
        for j=i:1:3
            a(i,1)=a(i,1)+lambda(j)*d(j,1);
            a(i,2)=a(i,2)+lambda(j)*d(j,2);
            a(i,3)=a(i,3)+lambda(j)*d(j,3);
        end
    end
end
b=a;
for i=1:1:3 %так как при i=1 b=a
    if(i==1)
        lenB=sqrt(b(i,1)*b(i,1)+b(i,2)*b(i,2)+b(i,3)*b(i,3));
        d(i,1)=b(i,1)/lenB;
        d(i,2)=b(i,2)/lenB;
        d(i,3)=b(i,3)/lenB;
    else
        for j=1:1:i-1
        b(i,1)=b(i,1)-((a(i,1)*d(j,1)+a(i,2)*d(j,2)+a(i,3)*d(j,3))*d(j,1));
        b(i,2)=b(i,2)-((a(i,1)*d(j,1)+a(i,2)*d(j,2)+a(i,3)*d(j,3))*d(j,2));
        b(i,3)=b(i,3)-((a(i,1)*d(j,1)+a(i,2)*d(j,2)+a(i,3)*d(j,3))*d(j,3));   
        end
        lenB=sqrt(b(i,1)*b(i,1)+b(i,2)*b(i,2)+b(i,3)*b(i,3));
        d(i,1)=b(i,1)/lenB;
        d(i,2)=b(i,2)/lenB;
        d(i,3)=b(i,3)/lenB;
    end
end         
a
b
d
lambda
res = d;
end

