function haar = rand_haar_state(options)
    arguments
        options.J (1,1) double {mustBeHalfInteger};
    end
    J = options.J;
    dim = 2*J+1;
    haar = randn(dim,1) + 1j*randn(dim,1);
    haar = haar/norm(haar);
end