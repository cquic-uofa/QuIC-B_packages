function U = pSpin_U(h,Lambda,p,t,options)
    arguments
        h (1,1) double
        Lambda (1,1) double
        p (1,1) double {mustBeInteger}
        t (1,1) double
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
        options.lin (1,1) string {mustBeMember(options.lin,["x","y","z"])} = "x";
        options.nonlin (1,1) string {mustBeMember(options.nonlin,["x","y","z"])} = "z";
        options.convention (1,1) string {mustBeMember(options.convention,["Standard","Reversed"])} = "Standard";
    end
    H = quic_tools.pSpin_H(h,Lambda,p,J=options.J,lin=options.lin,nonlin=options.nonlin,convention=options.convention);
    [V,D] = eig(H,'vector');
    U = V * diag(exp(-1j*D*t)) * V';
    % U = expm(-1j*H*t);

end