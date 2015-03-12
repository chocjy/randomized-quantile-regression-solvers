% About:
%   This code generates experiments on large-scale quantile regression by using randomized sampling.
%   It investigates the performance of several conditioning methods as the quantile parameter changes by using certain sampling size.
%
% Author:
%   Jiyan Yang (jiyan@stanford.edu)

clear all
close all

%-----------------Parameters can be modified-----------------
s_vec = [1e3, 1e4, 1e5];
%tau_vec = 0.5:0.02:0.96;
%tau_vec = [tau_vec, 0.965, 0.97, 0.975, 0.98, 0.985, 0.99, 0.995, 0.999];
tau_vec = 0.5:0.1:0.9;
ns = numel(s_vec);
ntau = numel(tau_vec);
n = 1e6;
d = 50;

K = 5;   %number of indepedent trials
M = 5;   %number of methods
method_gen_data = 2;  %method for generating data

use_existed_data = 0;

order = 1; %it appears in the filename for this experiment
ipm_order = 1;
dir = '~/quantreg/empirical_results/testing/';

methods = cell(M, 1);

methods{1} = struct( 'name', 'SPC1', 'unif', 0, 'func', @condition_spc );
methods{2} = struct( 'name', 'SPC2', 'unif', 0, 'func', @condition_spc2 );
methods{3} = struct( 'name', 'SPC3', 'unif', 0, 'func', @condition_spc3 );
methods{4} = struct( 'name', 'NOCO', 'unif', 0, 'func', @condition_no );
methods{5} = struct( 'name', 'UNIF', 'unif', 1, 'func', @rotation_no );
%------------------------------------------------------------

if use_existed_data
  eval(['load ', ['tau_ipm_data', num2str(ipm_order)]])

else
  %Generate dat.
  switch method_gen_data
    case 1
      %data1
      [A, b] = gen_data_1(n, d);

    case 2  
      %data2
      [A b] = gen_data_2(n, d);

    case 3
      %data3
      load census_data
      [n d] = size(A);
  end


  %Use IPM to compute the opt solution and objective.

  x_opt = quantreg_ipm(A, b, tau_vec);
  f_opt = quant_loss_func(repmat(b, 1, ntau) - A*x_opt, tau_vec);

  fname = [dir, 'err_tau', '_results', num2str(order)];
  mkdir(fname);

  save(fullfile(fname, ['tau_ipm_data', num2str(ipm_order)]), 'A')
  save(fullfile(fname, ['tau_ipm_data', num2str(ipm_order)]), 'b', '-append')
  save(fullfile(fname, ['tau_ipm_data', num2str(ipm_order)]), 'n', '-append')
  save(fullfile(fname, ['tau_ipm_data', num2str(ipm_order)]), 'd', '-append')
  save(fullfile(fname, ['tau_ipm_data', num2str(ipm_order)]), 'tau_vec', '-append')
  save(fullfile(fname, ['tau_ipm_data', num2str(ipm_order)]), 'x_opt', '-append')
  save(fullfile(fname, ['tau_ipm_data', num2str(ipm_order)]), 'f_opt', '-append')
  save(fullfile(fname, ['tau_ipm_data', num2str(ipm_order)]), 'method_gen_data', '-append')

end


%Save all the information into data structure.

data.s_vec = s_vec;
data.ns = ns;
data.n = n;
data.d = d;
data.tau_vec = tau_vec;
data.ntau = ntau;
data.method_gen_data = method_gen_data;
data.K = K;
data.M = M;
data.order = order;
data.filename = 'err_tau';
data.current_time = datestr(now, 'mmm-dd-yyyy HH:MM:SS')


%For each method, implement it for K times for each combination of tau and s. 

for i = 1:M

    c = methods{i};

    methods{i}.errors = cell(4,1);

    methods{i}.errors{1} = struct('name', 'objective value', 'ylabel', '|f-f^*|/|f^*|');
    methods{i}.errors{2} = struct('name', 'solution', 'ylabel', '||x-x^*||_2/||x^*||_2');
    methods{i}.errors{3} = struct('name', 'solution with l1 error', 'ylabel', '||x-x^*||_1/||x^*||_1');
    methods{i}.errors{4} = struct('name', 'solution with entry-wise absolute error', 'ylabel', '||x-x^*||_\infty/||x^*||_\infty');

    for t = 1:4
        methods{i}.errors{t}.err_mat = zeros(ntau, K, ns);
    end
    
    for j = 1:ns

      for k = 1:K
        [i j k]
      
        x = quantreg_samp(A, b, tau_vec, s_vec(j), c.unif, c.func);
        f = quant_loss_func(repmat(b, 1, ntau) - A*x, tau_vec);

        methods{i}.errors{1}.err_mat(:,k,j) = abs((f - f_opt)./f_opt);
        methods{i}.errors{2}.err_mat(:,k,j) = sqrt(sum((x - x_opt).^2, 1))./sqrt(sum(x_opt.^2, 1));
        methods{i}.errors{3}.err_mat(:,k,j) = sum(abs(x - x_opt), 1)./sum(abs(x_opt), 1);
        methods{i}.errors{4}.err_mat(:,k,j) = max(abs(x - x_opt), [], 1)./max(abs(x_opt), [], 1);
      end

      for l = 1:ntau
        for t = 1:4
          vec = methods{i}.errors{t}.err_mat(l,:,j);
          vec(isnan(vec)) = 1e16;
          q = quantile(vec, [0.25, 0.75]);
          methods{i}.errors{t}.q1(j,l) = q(1);
          methods{i}.errors{t}.q3(j,l) = q(2);
        end
      end     
    
    end

end


%saving data
data.methods = methods;
save_data(data, dir);

%plotting
plot_err_tau;

