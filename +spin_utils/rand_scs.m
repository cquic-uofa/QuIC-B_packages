function scs = rand_scs(options)
    arguments
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative};
    end

    n = randn(3,1);
    n = n/norm(n);
    % options.J = J;
    options.convention = "Standard";
    scs = spin_utils.scs_from_unit_vector(n,J=options.J,convention=options.convention); % TODO check to make sure this works
    
end