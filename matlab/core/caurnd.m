function y = caurnd( shape, mu, gamma )
% CAURND generates random Cauchy numbers
    
    if nargin < 2 || isempty(mu)
        mu = 0;
    end
    
    if nargin < 3 || isempty(gamma)
        gamma = 1;
    end
    
    x = rand(shape);
    y = mu + gamma * tan(pi*(x-0.5));
    
end
