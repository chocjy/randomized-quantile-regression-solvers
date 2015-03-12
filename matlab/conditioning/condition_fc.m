function [B, R] = condition_fc(A)
    
    [m, n] = size(A);
    
    s = 2^ceil(log((2*n*log(n))^2)/log(2));
    H = hadamard(s)/sqrt(s);
    X = [zeros(m,n); A];
    for i=1:m/s
        ii = (i-1)*s+1:i*s;
        X(ii, :) = H*A(ii, :);
    end
    c = caurnd([2*m,1]);
    r = ceil(2*n*log(n));
    S = zeros(r,2*m);
    idx = ceil(r*rand(2*m,1));
    for j=1:2*m
        S(idx(j),j) = 1;
    end
    As = S*diag(sparse(c))*X;
    [Qs, R] = qr(As, 0);
    B = A/R;
    
end
