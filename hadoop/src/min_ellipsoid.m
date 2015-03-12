function B1 = min_ellipsoid(B, a, c)
% x^T B1^{-1} x <= 1 is the min-vol ellipoid containing 
% {x^T B^{-1} x <=1} and {a'*x <= c} and {a'*x >= -c}
    
    n = size(B, 1);

    if c <= 0
        error('c must be positive.');
    end
    
    Ba    = B*a;
    aBa   = a'*Ba;
    alpha = c/sqrt(aBa);

    if alpha >= 1/sqrt(n)
        B1 = B;
        return;
    end
    
    sigma = (1-n*alpha^2)/(1-alpha^2);
    delta = n*(1-alpha^2)/(n-1);
    
    B1 = delta*(B - sigma/aBa * Ba*Ba');
    
end
