function [jx,jy,jz] = ang_mom(options)
    arguments
        options.J (1,1) double {mustBeHalfInteger};
        options.convention (1,1) string {mustBeMember(options.convention,["Standard","Reversed"])} = "Standard";
    end
    % norm of spin matrix is J*(J+1)*(2*J+1)/3
    J = options.J;
    m = J-1:-1:-J;
    v = sqrt(J*(J+1)-m.*(m+1));
    jx = (diag(v,1)+diag(v,-1))/2;
    
    if strcmp(options.convention,"Standard")
        jy = (diag(v,1) + diag(-v,-1))/(2i);
        jz = diag(J:-1:-J);
    elseif strcmp(options.convention,"Reversed")
        jy = (diag(-v,1) + diag(v,-1))/(2i); % TODO check if this is correct
        jz = diag(-J:1:J);
    end

end