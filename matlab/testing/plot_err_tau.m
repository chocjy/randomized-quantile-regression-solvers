methods = data.methods;

names = cell(data.ns, 1);
for i = 1:data.ns
    names{i} = ['s = ', num2str(data.s_vec(i))];
end

colors = {'r', 'b', 'g', 'k', 'm', 'y'};

%plotting error

for t = 1:4
  for i = 1:data.M
    ha = figure

    hh = zeros(data.ns, 1);

    hold on

    c = methods{i};

    %plotting curves
    for l = 1:data.ns
      hh(l) = plot(data.tau_vec, c.errors{t}.q1(l,:), [colors{l}, '-'], 'LineWidth', 2);
      plot(data.tau_vec, c.errors{t}.q3(l,:), [colors{l}, '--'], 'LineWidth', 2);
    end

    %setting axis
    xlim([0.5,1])
    xti = 0.5:0.1:1;

    if t == 1
      ylim([1e-6, 100])
      yti = [1e-6, 1e-4, 1e-2, 1, 1e2];
    else
      ylim([1e-4, 100])
      yti = [1e-4, 1e-2, 1, 1e2];
    end

    set(gca, 'Yscale', 'log', 'Xtick', xti, 'Ytick', yti, 'FontSize', 30);

    %legend, label, title
    legend(hh, names, 'Location', 'Northwest', 'FontSize', 23);

    xlabel('\tau', 'FontSize', 28);
    ylabel(c.errors{t}.ylabel, 'FontSize', 28);

    title(['Method = ', c.name], 'FontSize', 28);

    hold off

    %saving figures
    fname = [dir, data.filename, '_results', num2str(data.order)];
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.M+i)]), 'pdf')
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.M+i)]), 'fig')
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.M+i)]), 'epsc')

  end
end



