function [B, R] = condition_none(A)
   
    [n, d] = size(A);
    
    B = A;
    R = eye(d);
    
end
