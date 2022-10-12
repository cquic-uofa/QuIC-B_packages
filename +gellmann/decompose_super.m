function r = decompose_super(A,basis)
    %
    % gellmann.decompose_super(A,basis)
    % Converts operator to vector in gellmann basis
    %    
    % Arguments:
    %     A     : operator (Hermitian matrix for real vector)
    %     basis : matrix of basis elements of shape (dim^2,dim^2) 
    %                    (output from gellmann.gen_basis_super(dim))
    % Output:
    %     r     : vector (real for Hermitian operator)
    % 
    [d,d1] = size(A);
    assert(d==d1,'Input operator must be square')
    if nargin<2
        basis = gellmann.gen_basis_super(d);
    else
        [d2,~] = size(basis);
        assert(d2==d^2,'Dimension of basis does not match input')
    end
    r = basis'*vec(A);
end