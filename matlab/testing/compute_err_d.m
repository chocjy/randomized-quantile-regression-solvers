% About:
%   This code generates experiments on large-scale quantile regression by using randomized sampling.
%   It investigates the performance of a fixed conditioning method as the lower dimension of the dataset changes.
%   Mutiple sampling sizes and quantile parameters are considered.
%
% Author:
%   Jiyan Yang (jiyan@stanford.edu)

clear all
close all

%-----------------Parameters can be modified-----------------
s_vec = [1e3, 1e4, 1e5];
ns = numel(s_vec);
d_vec = [10, 30, 50];
nd = numel(d_vec);
tau_vec = [0.5, 0.75, 0.95];
ntau = numel(tau_vec);
n  = 1e5;

K = 5;
method_gen_data = 2;
method = struct( 'name', 'SPC3', 'unif', 0, 'func', @condition_spc3 );

order = 1;
dir = '~/quantreg/empirical_results/testing/';
%------------------------------------------------------------

switch method_gen_data
  case 1
    %data1
    gen_data = @gen_data_1;

  case 2
    %data2
    gen_data = @gen_data_2;
end


%Stroe data
data.s_vec = s_vec;
data.ns = ns;
data.d_vec = d_vec;
data.nd = nd;
data.n = n;
data.tau_vec = tau_vec;
data.ntau = ntau;
data.K = K;
data.method_gen_data = method_gen_data;
data.order = order;
data.filename = 'err_d';
data.current_time = datestr(now, 'mmm-dd-yyyy HH:MM:SS')


%setting variables
method.errors = cell(4,1);

method.errors{1} = struct('name', 'objective value', 'ylabel', '|f-f^*|/|f^*|');
method.errors{2} = struct('name', 'solution', 'ylabel', '||x-x^*||_2/||x^*||_2');
method.errors{3} = struct('name', 'solution with l1 error', 'ylabel', '||x-x^*||_1/||x^*||_1');
method.errors{4} = struct('name', 'solution with entry-wise absolute error', 'ylabel', '||x-x^*||_\infty/||x^*||_\infty');

for t = 1:4
  method.errors{t}.err_mat = zeros(ntau, K, ns, nd);
end


%Run experiment for each d.
for i = 1:nd

  [As, bs] = gen_data(n, d_vec(i));
  x_opt = quantreg_ipm(As, bs, tau_vec);
  f_opt = quant_loss_func(repmat(bs, 1, ntau) - As*x_opt, tau_vec);

  for j = 1:ns

    for k = 1:K     
    [i j k]

    x = quantreg_samp(As, bs, tau_vec, s_vec(j), method.unif, method.func);
    f = quant_loss_func(repmat(bs, 1, ntau) - As*x, tau_vec);

    method.errors{1}.err_mat(:,k,j,i) = abs((f - f_opt)./f_opt);
    method.errors{2}.err_mat(:,k,j,i) = sqrt(sum((x - x_opt).^2, 1))./sqrt(sum(x_opt.^2, 1));
    method.errors{3}.err_mat(:,k,j,i) = sum(abs(x - x_opt), 1)./sum(abs(x_opt), 1);
    method.errors{4}.err_mat(:,k,j,i) = max(abs(x - x_opt), [], 1)./max(abs(x_opt), [], 1);
    
    end

    for l = 1:ntau
      for p = 1:4
        vec = method.errors{p}.err_mat(l,:,j,i);
        vec(isnan(vec)) = 1e16;
        q = quantile(vec, [0.25, 0.75]);
        method.errors{p}.q1(i,j,l) = q(1);
        method.errors{p}.q3(i,j,l) = q(2);
      end
    end

  end
 
end

%saving data
data.method = method;
save_data(data, dir);


%plotting figures
plot_err_d;


