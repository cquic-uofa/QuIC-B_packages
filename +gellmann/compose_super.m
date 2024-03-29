function A = compose_super(r,basis)
    %
    % gellmann.compose_super(r,basis)
    % Converts vector in gellmann basis to operator
    %    
    % Arguments:
    %     r     : vector (real for Hermitian matrix)
    %     basis : matrix of basis elements of shape (dim^2,dim^2)
    %                    (output from gellmann.gen_basis_super(dim))
    % Output:
    %     A     : operator (Hermitian for real vector)
    % 
    [d,~] = size(r);
    d = sqrt(d);
    assert(floor(d)==d,'Vector must be of perfect square dimension')
    if nargin<2
        basis = gellmann.gen_basis_super(d);
    else
        [d2,~] = size(basis);
        assert(d2==d^2,'Dimension of basis does not match input')
    end
    A = basis*r;
    A = reshape(A,d,d);
end