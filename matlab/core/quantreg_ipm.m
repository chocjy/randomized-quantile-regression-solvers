function x_vec = quantreg_ipm(A, b, tau_vec)

  [n, d] = size(A);

  n_tau = length(tau_vec);
  
  x_vec = zeros(d, n_tau);

  a = sum(A, 1)';
  
  for i = 1:n_tau
      rhs = (1-tau_vec(i)) * a;
      [~, z] = rqfnb(-b, A', rhs, ones(n, 1));
      x_vec(:, i)  = -z;
  end
      
end

