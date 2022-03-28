function H = rand_GUE(options)
    arguments
        options.J (1,1) double {mustBeHalfInteger};
    end
    J = options.J;
    dim = 2*J+1;

    H = randn(dim);
    V = diag(diag(H));
    L = (tril(H) - V)/2;
    U = (triu(H) - V)/2;
    H = V + (L + 1i*U) + (L.' - 1i*U.');

end