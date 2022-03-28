function basis = gen_basis_super(d)
    basis = zeros(d*d,d*d);
    basis(:,1) = vec(eye(d))/sqrt(d);
    for ii = 2:d
        basis(:,ii) = vec(diag([ones(1,ii-1), -(ii-1),zeros(1,d-1-(ii-1))]))/sqrt(ii*(ii-1));
    end
    ind = d+1;
    for ii = 2:d
        for jj = 1:ii-1
            basis_i = zeros(d);
            basis_i(ii,jj) = 1/sqrt(2);
            basis_i(jj,ii) = 1/sqrt(2);
            basis(:,ind) = vec(basis_i);
            basis_i(ii,jj) = 1i./sqrt(2);
            basis_i(jj,ii) = -1i./sqrt(2);
            basis(:,ind+1) = vec(basis_i);
            ind = ind+2;
        end
    end

end