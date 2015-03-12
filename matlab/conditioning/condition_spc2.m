function [B, R] = condition_spc2(A)
    
    [m, n] = size(A);

    %t = min(m, ceil(2*n^2*(log(n))^2));
    t = ceil(2*n^2*(log(n))^2); 
 
    Pi = sparse(ceil(t*rand(m, 1)), 1:m, caurnd([m, 1]));

    A1 = full(Pi*A);

    [Q, R1] = qr(A1, 0);

    v = sum(abs(A/R1), 2);
    sum_v = sum(v);

    s = 2*n^3*(log(n))^2;

    p = min(s*v/sum_v, 1.0);
    ii = rand(m, 1) < p;
    S = diag(sparse(1./p(ii)));

    As = S * A(ii, :);

    [Bs, R] = condition(As, 1);

    B = A/R;
    
end

