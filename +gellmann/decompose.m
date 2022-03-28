function r = decompose(A,basis)
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