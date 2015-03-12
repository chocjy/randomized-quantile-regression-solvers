function [B R] = condition_spc(A, ed) 

  [n d] = size(A);

  if nargin == 2
      t = ed;
  else
      t = ceil(2*d^2*(log(d))^2);
  end

  rn = ceil(rand(1, n)*t);
  C = sparse(rn, 1:n, caurnd([n,1]));
  As = C*A;

  [Q, R] = qr(As, 0);

  B = A/R;

end
