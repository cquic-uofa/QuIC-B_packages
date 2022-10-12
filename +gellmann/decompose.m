function r = decompose(A,basis)
    %
    % gellmann.decompose(A,basis)
    % Converts operator to vector in gellmann basis
    %    
    % Arguments:
    %     A     : operator (Hermitian matrix for real vector)
    %     basis : 3d array of basis elements of shape (dim^2,dim,dim) 
    %                    (output from gellmann.gen_basis(dim))
    % Output:
    %     r     : vector (real for Hermitian operator)
    % 
    [d,~] = size(A); % # assume square
    if nargin<2
        basis = gellmann.gen_basis(d);
    else
        [d2,~,~] = size(basis);
        assert(d2==d,'Dimension of basis does not match operator')
    end
    r = zeros(d^2,1);
    for ii = 1:d^2
        r(ii) = sum( A.' .* basis(:,:,ii), 'all' );
    end
end