function U = uni_qkt(s,t,options)
    arguments
        s (1,1) double
        t (1,1) double
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
        options.convention (1,1) string {mustBeValidConvention} = "Standard";
    end
    % TODO add linear and nonlinear options

    % following Kevin's conventions
    [jx,~,jz] = spin_utils.make_ang_mom(J=options.J,convention=options.convention);
    U = expm( 1i*(1-s)*jz*t )*expm( 1i*s*jx*jx*t/(2*J) );
end