function x = quantreg_pre(A, b, tau, s)
% QUANTREG_PRE implemnts a solver for strongly over-determined quantile regression
% problems with preproccessing by Portnoy and Koenker (1997).
    
    [m, n] = size(A);
    
    if nargin < 4 || isempty(s)
        %s = l1_reg_pre_ss(m,n);
        s = ceil(((n+1) * m)^(2/3)); 
   end
  
    if s >= m
        x = quantreg_ipm(A, b, tau);
        return;
    end

    [m, s]

    eps = 1e-6;
    num_fixup = 0;
    max_fixup = 3;
    
    ii  = randsample(m,s);
    As  = A(ii, :);
    bs  = b(ii);
    xs  = quantreg_ipm(As, bs, tau);
    rs  = b - A*xs;
    Rs  = qr(As,0);
    Rs  = triu(Rs(1:n, :));
    bw  = sqrt(sum((A/Rs).^2, 2));
    % Rs = qr(rdct(As, 4*n), 0);
    % Rs = triu(Rs(1:n, :));
    % C  = 2*((rand(n,ceil(4*log(n)))>0.5)-0.5) / sqrt(ceil(4*log(n)));
    % bw = sqrt(sum((A*(Rs\C)).^2, 2));
    bm = bw;
    bm(bw<eps) = eps;
    rr  = rs./bm;
    factor = 0.8;
    k   = s * factor;
    lo_q = max(1/m, tau - k/(2 * m));
    hi_q = min(tau + k/(2 * m), (m - 1)/m);
    kappa = quantile(rr, [lo_q, hi_q]);
    ii_n = rs < bw*kappa(1);
    ii_p = rs > bw*kappa(2);

    optimal = false;
    while ~optimal
        if num_fixup == max_fixup
            x = quantreg_pre(A, b, tau, 2*s);
            break;
        end         
 
        ii = ~ii_n & ~ii_p;
        As = A(ii,:);
        bs = b(ii);
        
        if any(ii_n)
            glob_a = sum(A(ii_n,:),1);
            glob_b = sum(b(ii_n));
            As = [As; glob_a];
            bs = [bs; glob_b];
        end
        
        if any(ii_p)
            glob_a = sum(A(ii_p,:),1);
            glob_b = sum(b(ii_p));
            As = [As; glob_a];
            bs = [bs; glob_b];
        end
        
        length(bs)

        xs = quantreg_ipm(As, bs, tau);
        rs = b - A*xs;
        
        ii_p_bad = (rs < 0) & ii_p;
        ii_n_bad = (rs > 0) & ii_n;

        n_bad = sum(ii_p_bad)+sum(ii_n_bad);

        if n_bad == 0
            optimal = true;
            x = xs;
        elseif n_bad > 0.1*k              % too many bad guesses
            x = quantreg_pre(A, b, tau, 2*s);
            break;
        else
            ii_p = ii_p & ~ii_p_bad;
            ii_n = ii_n & ~ii_n_bad;
            num_fixup = num_fixup + 1;
        end
        
    end
end

