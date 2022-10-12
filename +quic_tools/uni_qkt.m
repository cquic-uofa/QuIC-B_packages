function U = uni_qkt(s,t,options)
    arguments
        s (1,1) double
        t (1,1) double
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
        options.lin (1,1) string {mustBeMember(options.lin,['x','y','z'])} = 'z';
        options.nonlin (1,1) string {mustBeMember(options.nonlin,['x','y','z'])} = 'x';
        options.convention (1,1) string {mustBeMember(options.convention,["Standard","Reversed"])} = "Standard";
    end
    % TODO add linear and nonlinear options
    [jx,jy,jz] = spin_utils.ang_mom(J=options.J,convention=options.convention);
    types = ["x","y","z"];
    angs = {jx,jy,jz};

    lin_op = angs{strcmp(options.lin,types)};
    nonlin_op = angs{strcmp(options.nonlin,types)};
    
    % following Kevin's conventions
    U = expm( 1i*(1-s)*lin_op*t )*expm( 1i*s*nonlin_op*nonlin_op*t/(2*J) );
end