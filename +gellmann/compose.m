function A = compose(r,basis)
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