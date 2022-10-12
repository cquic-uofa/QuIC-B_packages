function A = compose(r,basis)
    %
    % gellmann.compose(r,basis)
    % Converts vector in gellmann basis to operator
    %    
    % Arguments:
    %     r     : vector (real for Hermitian matrix)
    %     basis : 3d array of basis elements of shape (dim^2,dim,dim) 
    %                    (output from gellmann.gen_basis(dim))
    % Output:
    %     A     : operator (Hermitian for real vector)
    % 

    [d,~] = size(r);
    d = sqrt(d);
    if nargin<2
        basis = gellmann.gen_basis(d);
    else
        [d2,~,~] = size(basis);
        assert(d2==d,'Dimension of basis does not match input')
    end
    A = zeros(d);
    for ii = 1:d^2
        A = A + basis(:,:,ii)*r(ii);
    end

end