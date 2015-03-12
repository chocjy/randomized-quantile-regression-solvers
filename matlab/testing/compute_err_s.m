%   This code generates experiments on large-scale quantile regression by using randomized sampling.
%   It investigates the performance of several conditioning methods as the sampling size s changes.
%   Several quantile parameters are considered.
%
% Author:
%   Jiyan Yang (jiyan@stanford.edu)

clear all
close all

%-----------------Parameters can be modified-----------------
s_vec = [1e2, 1e3, 1e4];
tau_vec = [0.5, 0.75, 0.95];
ns = numel(s_vec);
ntau = numel(tau_vec);

n = 1e5;
d = 50; 

K = 5;   %number of indepedent trials
method_gen_data = 2;  %method for generating data
M = 6;   %number of methods

dir = '~/quantreg/empirical_results/testing/';
order = 1;  %it appears in the filename for this experiment

methods = cell(M, 1);

methods{1} = struct( 'name', 'SC', 'color', 'm', 'unif', 0, 'func', @condition_sc );
methods{2} = struct( 'name', 'SPC1', 'color', 'r', 'unif', 0, 'func', @condition_spc );
methods{3} = struct( 'name', 'SPC2', 'color', 'b', 'unif', 0, 'func', @condition_spc2 );
methods{4} = struct( 'name', 'SPC3', 'color', 'g', 'unif', 0, 'func', @condition_spc3 );
methods{5} = struct( 'name', 'NOCO', 'color', 'c', 'unif', 0, 'func', @condition_no );
methods{6} = struct( 'name', 'UNIF', 'color', 'k', 'unif', 1, 'func', @rotation_no );
%------------------------------------------------------------

%Generate data.

switch method_gen_data
  case 1
    %data1
    [A, b] = gen_data_1(n, d, 0.2, 0.001, 500);

  case 2  
    %data2
    [A b] = gen_data_2(n, d, 0.8, 0.2, 0.001, 500);

  case 3
    %data3
    load census_data
    [n d] = size(A);
end


%Use IPM to compute the opt solution and objective.

tic
x_opt = quantreg_ipm(A, b, tau_vec);
t_ipm = toc;
f_opt = quant_loss_func(repmat(b, 1, ntau) - A*x_opt, tau_vec);


%Save all the information into data structure.

data.s_vec = s_vec;
data.ns = ns;
data.n = n;
data.d = d;
data.M = M;
data.tau_vec = tau_vec;
data.ntau = ntau;
data.method_gen_data = method_gen_data;
data.K = K;
data.order = order;
data.filename = 'err_s';
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

    methods{i}.t_mat = zeros(K, ns);
    
    for j = 1:ns

      for k = 1:K
        [i j k]
      
        tic;
        x = quantreg_samp(A, b, tau_vec, s_vec(j), c.unif, c.func);
        t = toc;
        f = quant_loss_func(repmat(b, 1, ntau) - A*x, tau_vec);

        methods{i}.errors{1}.err_mat(:,k,j) = abs((f - f_opt)./f_opt);
        methods{i}.errors{2}.err_mat(:,k,j) = sqrt(sum((x - x_opt).^2, 1))./sqrt(sum(x_opt.^2, 1));
        methods{i}.errors{3}.err_mat(:,k,j) = sum(abs(x - x_opt), 1)./sum(abs(x_opt), 1);
        methods{i}.errors{4}.err_mat(:,k,j) = max(abs(x - x_opt), [], 1)./max(abs(x_opt), [], 1);
        methods{i}.t_mat(k,j) = t;
      end

      for l = 1:ntau
        for p = 1:4
          vec = methods{i}.errors{p}.err_mat(l,:,j);
          vec(isnan(vec)) = 1e16;
          q = quantile(vec, [0.25, 0.75]);
          methods{i}.errors{p}.q1(j,l) = q(1);
          methods{i}.errors{p}.q3(j,l) = q(2);
        end
      end     

      methods{i}.time(j) = mean(methods{i}.t_mat(:,j));
    
    end

end


%saving data
data.methods = methods;
save_data(data, dir);


%plotting
plot_err_s;

