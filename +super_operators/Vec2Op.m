function op = Vec2Op(vec)
    N = sqrt(length(vec)); % should error check this
    if N ~= floor(N)
        error('Vector length must be perfect square')
    end
    op = reshape(vec,N,N);
end