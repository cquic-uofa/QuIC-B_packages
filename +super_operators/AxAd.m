function M = AxAd(A)
    % A is (dim,dim)
    % M is (dim^2,dim^2)
    [~,dim] = size(A);
    M = zeros(dim^2,dim^2);
    for ii = 0:(dim^2-1)
        for jj = 0:(dim^2-1)
            M(jj+1,ii+1) = A(floor(jj/dim)+1,floor(ii/dim)+1)'*A(mod(jj,dim)+1,mod(ii,dim)+1);
        end
    end
end