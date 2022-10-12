function H = pSpin_H(h,Lambda,p,options)
    arguments
        h (1,1) double
        Lambda (1,1) double
        p (1,1) double {mustBeInteger}
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
    
    H = -h*lin_op - Lambda*(nonlin_op^p)/(p*(options.J^(p-1)));

end