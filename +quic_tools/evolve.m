function expect = evolve(psi,op,U,n)

    expect = zeros(n,1);

    
    for ii = 1:n
        expect(ii) = real(psi'*op*psi);
        psi = U*psi;
    end

end