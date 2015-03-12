function x_vec = quantreg_prqfn(A, b, tau_vec)

  [n, d] = size(A);

  n_tau = length(tau_vec);

  x_vec = zeros(d, n_tau);

  for i=1:n_tau
      z = quantreg_pre(A, b, tau_vec(i));
      x_vec(:, i)  = z;
  end

end

