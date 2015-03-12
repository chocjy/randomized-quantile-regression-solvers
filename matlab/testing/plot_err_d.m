names = cell(data.ns, 1);
for i = 1:data.ns
    names{i} = ['s = ', num2str(data.s_vec(i))];
end

colors = {'r', 'b', 'g', 'k', 'm', 'y'};

c = data.method;

%plotting
for t = 1:4
  for l = 1:data.ntau
    ha = figure

    hh = zeros(data.ns, 1);

    hold on

    %plotting curves
    for j = 1:data.ns

      hh(j) = plot(data.d_vec, c.errors{t}.q1(:,j,l), [colors{j}, '-'], 'LineWidth', 2);
      plot(data.d_vec, c.errors{t}.q3(:,j,l), [colors{j}, '--'], 'LineWidth', 2);
    end

    %setting axis
    %xlim([10, 100])

    if t == 1
      ylim([1e-6, 100])
      yti = [1e-6, 1e-4, 1e-2, 1, 1e2];
    else
      ylim([1e-4,100])
      yti = [1e-4, 1e-2, 1, 1e2];
    end

    set(gca, 'Yscale', 'log', 'Ytick', yti, 'FontSize', 30);

    %legend, label, title
    legend(hh, names, 'FontSize', 23);

    xlabel('d', 'FontSize', 28);
    ylabel(c.errors{t}.ylabel, 'FontSize', 28);

    title(['\tau = ', num2str(data.tau_vec(l))], 'FontSize', 28);

    hold off

    %saving figures
    fname = [dir, data.filename, '_results', num2str(data.order)];
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.ntau+l)]), 'pdf')
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.ntau+l)]), 'fig')
    saveas(ha, fullfile(fname, [data.filename, num2str(data.order), '_', num2str((t-1)*data.ntau+l)]), 'epsc')
  end
end

