function U = rand_haar_uni(options)
    % This algorithm follows the algorithm outlined in 
    %   Diaconis P., Shahshahani M. "The Subgroup Algorithm for Generating Uniform Random Variables" (2009)
    %
    % Draw random Unitary from circular orthogonal, unitary, or symplectic ensembles
    %
    % U = rand_haar_uni(options)
    %
    % arguments
    %     options.J (1,1) double {mustBeHalfInteger};
    %     options.ensemble (1,1) string {mustBeMember(options.ensemble,["Unitary","Orthogonal","Symplectic"])} = "Unitary";
    %     options.domain (1,1) string {mustBeMember(options.domain,["Complex","Real"])} = "Complex"; 
    % end

    arguments
        options.J (1,1) double {mustBeHalfInteger};
        options.ensemble (1,1) string {mustBeMember(options.ensemble,["Unitary","Orthogonal",...
                                                                      "Symplectic"])} = "Unitary";
        options.domain (1,1) string {mustBeMember(options.domain,["Complex","Real"])} = "Complex"; 
    end
    
    J = options.J;
    dim = 2*J+1;

    U = eye(dim);

    for ii = 2:dim

        v = randn(ii,1);
        if strcmp(options.domain,'Complex')
            v = v + 1i*randn(ii,1);
        end
        % this is a Householder transform
        v = v/norm(v);
        phi = v(end)/abs(v(end));
        v = v*phi';
        v(end) = v(end)-1; % v is now dx
        v = v/norm(v);

        R = phi*(eye(ii)-2*(v*v'));
        U(1:ii,1:ii) = R*U(1:ii,1:ii);

    end

    if strcmp(options.ensemble,'Unitary')
        return
    elseif strcmp(options.ensemble,'Orthogonal')
        U = U.'*U;
    elseif strcmp(options.ensemble,'Symplectic')
        if mod(dim,2) == 1
            error('Symplectic matrix must have even dimension')
        end
        rot = zeros(dim);
        for jj = 1:(dim/2)
            rot(2*jj,2*jj-1) = 1;
            rot(2*jj-1,2*jj) = -1;
        end
        U = rot*U.'*rot.'*U;
    end

end