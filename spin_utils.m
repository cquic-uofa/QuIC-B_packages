classdef spin_utils
% standard tools for spin systems
% scs_from_unit_vector(n,J=7.5,convention="Standard")
% scs_from_polar_angles(theta,phi,J=7.5,convention="Standard")
% rand_scs(J)
% rand_haar_state(J)
% rand_haar_uni(J,ensemble="Unitary",domain="Complex")
% ang_mom(J,convention="Standard")

% conventions are Standard {J,J-1,...-J} or Reversed {-J,-J+1,...J}
% ensembles are {'Unitary','Orthogonal','Symplectic'}

methods (Static)

    function scs = scs_from_unit_vector(n,options)
        arguments
            n (3,1) double {mustBeUnitVector};
            options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
            options.convention (1,1) string = "Standard";
        end

        % generates spin coherent state from unit vector n in subspace with angular momentum J
        
        dim = 2*options.J+1;
        
        nn = dim-1; % % dimension - 1 (not to be confused with n)
        
        phi = atan2(n(2),n(1));  % azimuthal angle
        
        if strcmp(options.convention,"Standard")
            s = 1;
            ind = nn+1;
        elseif strcmp(options.convention,"Reversed")
            s = -1;
            ind = 1;
        else
            error("Spin convention not recognized")
        end    
        
        p = (s*n(3)+1)/2;      % stands in for altitude angle
        
        % working in log space so funciton works for large spin
        base = nn*log(p)/2;
        step = (log(1-p)-log(p))/2;
        
        r = (0:nn)';
        phase = exp(1i*phi*r);
        
        % base + step*r
        % each step multiply by sqrt((1-p)/p)  % multiply by phase later
        scs = zeros(dim,1);
        if n(3)==1
            scs(ind) = 1;
            return
        end
        % if not special case, proceed to calculate binomial
        scs(1) = base;
        
        for ii = 2:(nn+1)
            scs(ii) = scs(ii-1) + step + log( (nn-ii+2)/(ii-1) )/2;
        end
        scs = exp(scs).*phase;
        scs = scs / norm(scs);
        
    end

    function scs = scs_from_polar_angles(theta,phi,options)
        arguments
            theta (1,1) double;
            phi (1,1) double;
            options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
            options.convention (1,1) string = "Standard";
        end
        
        n = [sin(theta)*cos(phi),sin(theta)*sin(phi),cos(theta)];
        scs = spin_utils.scs_from_unit_vector(n,J=options.J,convention=options.convention); % TODO check to make sure this works
        
    end

    function scs = rand_scs(J)
        arguments
            J (1,1) double {mustBeHalfInteger,mustBeNonnegative};
        end

        n = randn(3,1);
        n = n/norm(n);
        options.J = J;
        options.convention = "Standard";
        scs = spin_utils.scs_from_unit_vector(n,J=options.J,convention=options.convention); % TODO check to make sure this works
        
    end

    function haar = rand_haar_state(J)
        arguments
            J (1,1) double {mustBeHalfInteger};
        end
        dim = 2*J+1;
        haar = randn(dim,1) + 1j*randn(dim,1);
        haar = haar/norm(haar);
    end

    function U = rand_haar_uni(J,options)
        % This algorithm follows the algorithm outlined in 
        %   Diaconis P., Shahshahani M. "The Subgroup Algorithm for Generating Uniform Random Variables" (2009)
        %
        % Draw random Unitary from circular orthogonal, unitary, or symplectic ensembles
        %
        arguments
            J (1,1) double {mustBeHalfInteger};
            options.ensemble (1,1) string = "Unitary";
            options.domain (1,1) string {mustBeValidDomain} = "Complex"; 
        end

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
        else
            error('Ensemble not recognized')
        end

    end

    function H = rand_GUE(J)
        arguments
            J (1,1) double {mustBeHalfInteger};
        end

        dim = 2*J+1;

        H = randn(dim);
        V = diag(diag(H));
        L = (tril(H) - V)/2;
        U = (triu(H) - V)/2;
        H = V + (L + 1i*U) + (L.' - 1i*U.');

    end

    function [jx,jy,jz] = ang_mom(J,options)
        arguments
            J (1,1) double {mustBeHalfInteger};
            options.convention (1,1) string = "Standard";
        end
        % norm of spin matrix is J*(J+1)*(2*J+1)/3
        m = J-1:-1:-J;
        v = sqrt(J*(J+1)-m.*(m+1));
        jx = (diag(v,1)+diag(v,-1))/2;

        
        jp = diag(sqrt(J*(J+1)-m.*(m+1)),-1);
        jx = (jp + jp')/2;
        
        if strcmp(options.convention,"Standard")
            jy = (diag(v,1) + diag(-v,-1))/(2i);
            jz = diag(J:-1:-J);
        elseif strcmp(options.convention,"Reversed")
            jy = (diag(-v,1) + diag(v,-1))/(2i); % TODO check if this is correct
            jz = diag(-J:1:J);
        else
            error('Spin convention not recognized')
        end

    end
end

end

function mustBeHalfInteger(J)
    if ~(floor(2*J)==2*J)
        eidType = 'mustBeHalfInteger:notHalfInteger';
        msgType = 'Input must be integer or half integer.';
        throwAsCaller(MException(eidType,msgType))
    end
end

function mustBeUnitVector(n)
    if ~(abs(norm(n)-1)<(1.5*eps)) % n/norm(n) is good to +/- eps
        eidType = 'mustBeUnitVector:notUnitVector';
        msgType = 'Input must be unit vector.';
        throwAsCaller(MException(eidType,msgType))
    end
end

function mustBeValidDomain(domain)
    if ~(strcmp(domain,"Complex")||strcmp(domain,"Real"))
        eidType = 'mustBeValidDomain:notValidDomain';
        msgType = 'Domain must be Complex or Real.';
        throwAsCaller(MException(eidType,msgType))
    end
end