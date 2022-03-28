function op = DVec2Op(dvec)
    N = sqrt(length(dvec)); % should error check this
    if N ~= floor(N)
        error('Dual vector length must be perfect square')
    end
    op = reshape(dvec',N,N);
end