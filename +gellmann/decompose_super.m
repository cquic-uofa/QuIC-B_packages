function r = decompose_super(A,basis)
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