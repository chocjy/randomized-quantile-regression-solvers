function [B, R] = condition_sc(A)
    
    [m, n] = size(A);

    G  = caurnd([ceil(2*n*log(n)), m]);
    As = G*A;
    [Qs, R] = qr(As, 0);
    B  = A/R;
    
end
