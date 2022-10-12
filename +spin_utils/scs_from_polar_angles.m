function scs = scs_from_polar_angles(theta,phi,options)
    arguments
        theta (1,1) double;
        phi (1,1) double;
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
        options.convention (1,1) string {mustBeMember(options.convention,["Standard","Reversed"])} = "Standard";
    end
    
    n = [sin(theta)*cos(phi),sin(theta)*sin(phi),cos(theta)];
    scs = spin_utils.scs_from_unit_vector(n,J=options.J,convention=options.convention); % TODO check to make sure this works
    
end