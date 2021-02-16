function [a,sigma,error] = Gfit(x,y)
    g = @(A,X) A(1)*exp(-(X).^2/(2*A(2)^2));
    A0 = [150,1];
    [A1,error] = lsqcurvefit(g,A0,x,y);
    a = A1(1);
    sigma = A1(2);
    error = sqrt(error/length(x));
end