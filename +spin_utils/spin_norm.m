function n = spin_norm(J)
    arguments
        J (1,1) double {mustBeHalfInteger,mustBeNonnegative}
    end
% norm of spin matrix is J*(J+1)*(2*J+1)/3
    n = J*(J+1)*(2*J+1)/3;
end