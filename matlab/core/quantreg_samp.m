function x_vec = quantreg_samp(A, b, tau_vec, s, unif, func)

  [n, d] = size(A);
  d1     = d+1;

  Ab = [A, b];
  
  if unif == 0
    [B R] = func(Ab);

    v = sum(abs(B), 2);
    sum_v = sum(v);

    p = min(s*v/sum_v, 1.0);
    ii = rand(n, 1) < p;
    S = diag(sparse(1./p(ii)));

    Ai = S * A(ii, :);
    bi = S * b(ii);

    x_vec = quantreg_ipm(Ai, bi, tau_vec);
    
  else
    B = func(Ab);
      
    t = size(B,1);

    p  = min(s/t,1)*ones(t,1);
    ii = rand(t, 1) < p;
    S  = diag(sparse(1./p(ii)));

    Ai = S * B(ii, 1:end-1);
    bi = S * B(ii, end);

    x_vec = quantreg_ipm(Ai, bi, tau_vec);
     
  end

