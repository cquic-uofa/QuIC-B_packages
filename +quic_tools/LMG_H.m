function H = LMG_H(s,options)
    arguments
        s (1,1) double
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
        options.lin (1,1) string {mustBeMember(options.lin,["x","y","z"])} = "x";
        options.nonlin (1,1) string {mustBeMember(options.nonlin,["x","y","z"])} = "z";
        options.convention (1,1) string {mustBeMember(options.convention,["Standard","Reversed"])} = "Standard";
    end

    [jx,jy,jz] = spin_utils.ang_mom(J=options.J,convention=options.convention);
    types = ["x","y","z"];
    angs = {jx,jy,jz};

    lin_op = angs{strcmp(options.lin,types)};
    nonlin_op = angs{strcmp(options.nonlin,types)};
    
    H = -(1-s)*lin_op - s*(nonlin_op^2)/(2*options.J);

end
