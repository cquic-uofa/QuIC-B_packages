function A = compose_super(r,basis)
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