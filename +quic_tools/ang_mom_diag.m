function [D,Ux,Uy] = ang_mom_diag(options)
    arguments
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative};
        options.convention (1,1) string {mustBeMember(options.convention,["Standard","Reversed"])} = "Standard";
    end
    J = options.J;
    dim = 2*J+1;
    
    m = J-1:-1:-J;
    o = sqrt(J*(J+1)-m.*(m+1))/2;
    if strcmp(options.conention,"Standard")
        lstart = J;
        inc = -1;
    else
        lstart = -J;
        inc = 1;
    end
    d = lstart:inc:-lstart;
    
    % for diag in x
    D = diag(d);
    Ux = zeros(dim);
    Uy = zeros(dim);
    l = lstart;
    for jj = 1:dim
        v = zeros(dim,1);
        v(1) = 1;
        v(2) = l/o(1);
        for ii = 3:dim
            v(ii) = (l*v(ii-1)-o(ii-2)*v(ii-2))/o(ii-1);
        end
        Ux(:,jj) = v/norm(v);
        l = l+inc;
    end
    l = lstart;
    for jj = 1:dim
        v = zeros(dim,1);
        v(1) = 1;
        v(2) = -1j*l/o(1);
        for ii = 3:dim
            v(ii) = -1j*(l*v(ii-1)+1j*o(ii-2)*v(ii-2))/o(ii-1);
        end
        Uy(:,jj) = v/norm(v);
        l = l+inc;
    end
end