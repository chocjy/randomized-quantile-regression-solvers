methods = data.methods;

names = cell(data.M, 1);
for i = 1:data.M
    names{i} = methods{i}.name;
end

axis_s = 30;
label_s = 28;
legend_s = 23;

%plotting error

for t = 1:4
  for l = 1:data.ntau
    ha = figure

    hh = zeros(data.M, 1);
 
    hold on
  
    %plotting curves
    for i = 1:data.M
      c = methods{i};

      hh(i) = plot(data.s_vec, c.errors{t}.q1(:,l), [c.color, '-'], 'LineWidth', 2);   
      plot(data.s_vec, c.errors{t}.q3(:,l), [c.color, '--'], 'LineWidth', 2);    
    end
  
    %setting parameters for axis
    %xti = [100, 1e3, 1e4, 1e5, 1e6];

    if t == 1
      ylim([1e-6, 100])
      yti = [1e-6, 1e-4, 1e-2, 1, 1e2];
      legend_s1 = legend_s;
    else
      ylim([1e-4,100])
      yti = [1e-4, 1e-2, 1, 1e2];
      if data.tau_vec(l) < 0.95
        legend_s1 = legend_s;
      else
        legend_s1 = legend_s - 3;
      end
    end

    %set(gca, 'Xscale', 'log', 'Yscale', 'log', 'Xtick', xti, 'Ytick', yti, 'FontSize', axis_s);
    set(gca, 'Xscale', 'log', 'Yscale', 'log', 'Ytick', yti, 'FontSize', axis_s);

    %legend, label, title
    legend(hh, names, 'FontSize', legend_s1);

    xlabel('sample size', 'FontSize', label_s);
    ylabel(c.errors{t}.ylabel, 'FontSize', label_s);

    title(['\tau = ', num2str(data.tau_vec(l))], 'Fontsize', label_s);   

    hold off

    %saving figures
    fname = [dir, data.filename, '_results', num2str(data.order)]; 
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.ntau+l)]), 'pdf')
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.ntau+l)]), 'fig')
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.ntau+l)]), 'epsc')
  end
end


%plotting comparison of the running time for computing all tau

ha = figure

hh = zeros(data.M, 1);
 
hold on
  
for i = 1:data.M
  c = methods{i}; 
     
  hh(i) = plot(data.s_vec, c.time, [c.color, '-'], 'LineWidth', 2);   
    
end

set(gca, 'Xscale', 'log', 'Yscale', 'log', 'FontSize', 20);

legend(hh, names, 'Location', 'SouthEast', 'FontSize', 22);

xlabel('sample size', 'FontSize', 18);
ylabel('time', 'FontSize', 18);

title('The running time for each method', 'FontSize', 18);
   
hold off

fname = [dir, data.filename, '_results', num2str(data.order)];
saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str(4*data.ntau+1)]), 'pdf')
saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str(4*data.ntau+1)]), 'fig')
saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str(4*data.ntau+1)]), 'epsc')

