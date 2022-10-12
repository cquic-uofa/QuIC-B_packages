function basis = gen_basis(d)
    %
    % gellmann.gen_basis_super(dim)
    % Generates basis vectors of Gell-Mann basis as array of orthogonal
    % Hermitian matrices
    %    
    % Arguments:
    %     dim   : dimension of Hilbert space
    % Output:
    %     basis : 3d array of basis elements of shape (dim^2,dim,dim) 
    %                    (output from gellmann.gen_basis_super(dim))
    % 
    basis = zeros(d,d,d*d);
    basis(:,:,1) = eye(d)/sqrt(d);
    for ii = 2:d
        basis(:,:,ii) = diag([ones(1,ii-1), -(ii-1),zeros(1,d-1-(ii-1))])./sqrt(ii*(ii-1));
    end
    ind = d+1;
    for ii = 2:d
        for jj = 1:ii-1
            basis(ii,jj,ind) = 1./sqrt(2);
            basis(jj,ii,ind) = 1./sqrt(2);
            basis(ii,jj,ind+1) = 1i./sqrt(2);
            basis(jj,ii,ind+1) = -1i./sqrt(2);
            ind = ind+2;
        end
    end

end