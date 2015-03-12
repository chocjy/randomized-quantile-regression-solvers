function [B, R, kappa] = condition(A, p, s)
% CONDITION    (p,s)-conditioning
%     
% [B, R] = condition(A, p, s) computes a basis matrix B of range(A) and an upper
% triangular matrix R such that A = B R, and for all x in R^d, we have
% 
%     norm(x, s) <= norm(B*x, p) <= kappa * norm(x, s),
%
% where we guarantee that kappa <= 2*d^(1+abs(1/s-1/2)).
% 
    
    if nargin < 1 || isempty(A)
        error('Require at least one input.');
    end
    
    [n, d] = size(A);

    if nargin < 2 || isempty(p)
        p = 2;
    end

    if nargin < 3 || isempty(s)
        s = 2;
    end
    
    % orthogonalize A
    [B, R] = qr(A, 0);

    if p > 2
        alpha = n^(1/2-1/p);
        B = alpha*B;
        R = R/alpha;
    end

    kappa = n^abs(1/p-1/2);    
    
    if kappa > 2*d          % orth is not good enough for conditioning
        
        % \|B x\|_p <= 1 must be inside \|x\|_2 <= 1
        E = eye(d);
        
        maxit = ceil(3.2*abs(1/p-1/2)*d*log(n));
        for k=1:maxit

            E = (E+E')/2;
            [V, D] = eig(E);
            r = sqrt(diag(D));
            X = V * diag(sparse(r));
            
            feas = true;
            ii = randsample(d, d);
            for i=1:d
                x = X(:, ii(i));
                nrm_Bx = norm(B*x, p);
                if nrm_Bx > 2*sqrt(d)
                    feas = false;
                    a = sub_grad(x, B, p);
                    c = 1;
                    E = min_ellipsoid(E, a, c);
                    break;
                end
            end

            if feas
                break;
            end
            
        end
        
        if k == maxit
            warning('condition: max iter reached.');
        end
        
        RE = triu(qr(diag(sparse(1./r))*V', 0));
        B  = B/RE;
        R  = RE*R;
        
        kappa = 2*d;
        
    end
    
    if s < 2
        alpha = d^(1/s-1/2);
        B = alpha*B;
        R = R/alpha;
    end

    kappa = kappa * d^abs(1/s-1/2);
    
end

function g = sub_grad(x, A, p)

    Ax  = A*x;
    nrm = norm(Ax, p);
    
    if nrm == 0.0
        g = zeros(size(x));
        return;
    end
    
    if p == inf
        ii_p = Ax == nrm;
        ii_n = Ax == -nrm;
        g    = A' * (ii_p - ii_n) / (sum(ii_p) + sum(ii_n));
    elseif p == 1
        g    = A'*sign(Ax);
    else
        g    = nrm^(1-p) * (A' * (sign(Ax) .* abs(Ax).^(p-1)));
    end
    
end
