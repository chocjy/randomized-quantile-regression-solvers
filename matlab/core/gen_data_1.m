function [A b] = gen_data_1(n, d, scale, prob, mag)

  if nargin < 5
      mag = 500;
  end

  if nargin < 4
      prob = 0.001;
  end

  if nargin < 3
      scale = 0.2;
  end

  A       = [ones(n,1), randn(n, d-1)];
  x_exact = randn(d, 1);
  b_exact = A*x_exact;
  err     = laprnd([n, 1]);
  err     = scale * norm(b_exact)/norm(err) * err;
  b       = b_exact + err;
  ii      = rand(n, 1) < prob;
  b(ii)   = mag*err(ii);

