function value = quant_loss_func(X, tau)

    for i = 1:length(tau)
        a = X(:,i);
        value(i) = tau(i)*sum(sum(a)) - sum(a((a < 0)));
    end
