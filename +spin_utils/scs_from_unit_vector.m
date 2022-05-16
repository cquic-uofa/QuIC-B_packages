function scs = scs_from_unit_vector(n,options)
    arguments
        n (3,1) double {mustBeUnitVector};
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
        options.convention (1,1) string {mustBeValidConvention} = "Standard";
    end

    % generates spin coherent state from unit vector n in subspace with angular momentum J
    
    dim = 2*options.J+1;
    
    nn = dim-1; % % dimension - 1 (not to be confused with n)
    
    phi = atan2(n(2),n(1));  % azimuthal angle
    
    if strcmp(options.convention,"Standard")
        s = 1;
        ind = nn+1;
    elseif strcmp(options.convention,"Reversed")
        s = -1;
        ind = 1;
    else
        error("Spin convention not recognized")
    end    
    
    p = (s*n(3)+1)/2;      % stands in for altitude angle
    
    % working in log space so funciton works for large spin
    base = nn*log(p)/2;
    step = (log(1-p)-log(p))/2;
    
    r = (0:nn)';
    phase = exp(1i*phi*r);
    
    % base + step*r
    % each step multiply by sqrt((1-p)/p)  % multiply by phase later
    scs = zeros(dim,1);
    if n(3)==-1
        scs(ind) = 1;
        return
    end
    % if not special case, proceed to calculate binomial
    scs(1) = base;
    
    for ii = 2:(nn+1)
        scs(ii) = scs(ii-1) + step + log( (nn-ii+2)/(ii-1) )/2;
    end
    scs = exp(scs).*phase;
    scs = scs / norm(scs);
    
end