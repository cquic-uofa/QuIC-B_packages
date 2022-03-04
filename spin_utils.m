classdef spin_utils
% standard tools for spin systems
% scs_from_unit_vector(n,J[,con])
% scs_from_polar_angles(theta,phi,J[,con])
% make_rand_scs(J[,con])
% make_rand_haar_state(J)
% make_rand_haar_uni(J[,ens])
% make_ang_mom(J[,con])
% make_ang_mom_diag(J[,con])
% make_uni_qkt(s,t,J[,con])
% set_default_convention(con)

% conventions are standard {J,J-1,...-J} or bgrape {-J,-J+1,...J}
% ensembles are {'uni','ortho','symp'}

methods (Static)

    function scs = scs_from_unit_vector(n,J,con)
        if nargin==2
            con = spin_utils.get_default_convention();
        end
        if strcmp(con,'standard')
            scs = spin_utils.gen_scs_standard(n,J);
        elseif strcmp(con,'bgrape')
            scs = spin_utils.gen_scs_bgrape(n,J);
        else
            error('Spin convention not recognized')
        end
    end

    function scs = scs_from_polar_angles(theta,phi,J,con)
        if nargin==3
            con = spin_utils.get_default_convention();
        end
        n = [sin(theta)*cos(phi),sin(theta)*sin(phi),cos(theta)];
        if strcmp(con,'standard')
            scs = spin_utils.gen_scs_standard(n,J);
        elseif strcmp(con,'bgrape')
            scs = spin_utils.gen_scs_bgrape(n,J);
        else
            error('Spin convention not recognized')
        end
    end

    function scs = make_rand_scs(J,con)
        if nargin==1
            con = spin_utils.get_default_convention();
        end
        n = randn(1,3);
        n = n/norm(n);
        if strcmp(con,'standard')
            scs = spin_utils.gen_scs_standard(n,J);
        elseif strcmp(con,'bgrape')
            scs = spin_utils.gen_scs_bgrape(n,J);
        else
            error('Spin convention not recognized')
        end
    end

    function haar = make_rand_haar_state(J)
        dim = 2*J+1;
        spin_utils.error_check_spin(J);
        haar = randn(dim,1) + 1j*randn(dim,1);
        haar = haar/norm(haar);
    end

    function U = make_rand_haar_uni(J,ens,com)
        %
        % Draw random Unitary from circular orthogonal, unitary, or symplectic ensembles
        %
        %

        dim = 2*J+1;
        spin_utils.error_check_spin(J);

        if nargin == 1
            ens = 'uni';
            com = 'complex';
        end
        if nargin == 2
            com = 'complex';
        end

        U = eye(dim);

        for ii = 2:dim

            v = randn(ii,1);
            if strcmp(com,'complex')
                v = v + 1i*randn(ii,1);
            end
            v = v/norm(v);
            phi = v(end)/abs(v(end));
            v = v*phi';
            v(end) = v(end)-1; % v is now dx
            v = v/norm(v);

            R = phi*(eye(ii)-2*(v*v'));
            U(1:ii,1:ii) = R*U(1:ii,1:ii);

        end

        if strcmp(ens,'uni')
            return;
        elseif strcmp(ens,'ortho')
            U = U.'*U;
        elseif strcmp(ens,'symp')
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

    function H = make_rand_GUE(J)

        dim = 2*J+1;
        spin_utils.error_check_spin(J);

        H = randn(dim);
        V = diag(diag(H));
        L = (tril(H) - V)/2;
        U = (triu(H) - V)/2;
        H = V + (L + 1i*U) + (L.' - 1i*U.');

    end

    function [jx,jy,jz] = make_ang_mom(J,con)
        % norm of spin matrix is J*(J+1)*(2*J+1)/3

        spin_utils.error_check_spin(J);
        if nargin==1
            con = spin_utils.get_default_convention();
        end
        
        if strcmp(con,'standard')
            jz = diag(J:-1:-J);
        elseif strcmp(con,'bgrape')
            jz = diag(-J:1:J);
        else
            error('Spin convention not recognized')
        end
        m = J-1:-1:-J;
        jp = diag(sqrt(J*(J+1)-m.*(m+1)),-1);

        jx = (jp + jp')/2;
        jy = (jp - jp')/(2i);
    end

    function [D,Ux,Uy] = make_ang_mom_diag(J,con)
        spin_utils.error_check_spin(J);
        if nargin==1
            con = spin_utils.get_default_convention();
        end
        
        dim = 2*J+1;
        
        m = J-1:-1:-J;
        o = sqrt(J*(J+1)-m.*(m+1))/2;
        if strcmp(con,'standard')
            lstart = J;
            inc = -1;
        elseif strcmp(con,'bgrape')
            lstart = -J;
            inc = 1;
        else
            error('Spin convention not recognized')
        end
        d = lstart:inc:-lstart;
        
        % for diag in x
        D = diag(d);
        Ux = zeros(dim);
        Uy = zeros(dim);
        l = lstart;
        for jj = 1:dim
            vec = zeros(dim,1);
            vec(1) = 1;
            vec(2) = l/o(1);
            for ii = 3:dim
                vec(ii) = (l*vec(ii-1)-o(ii-2)*vec(ii-2))/o(ii-1);
            end
            Ux(:,jj) = vec/norm(vec);
            l = l+inc;
        end
        l = lstart;
        for jj = 1:dim
            vec = zeros(dim,1);
            vec(1) = 1;
            vec(2) = -1j*l/o(1);
            for ii = 3:dim
                vec(ii) = -1j*(l*vec(ii-1)+1j*o(ii-2)*vec(ii-2))/o(ii-1);
            end
            Uy(:,jj) = vec/norm(vec);
            l = l+inc;
        end
    end


    function U = make_uni_qkt(s,t,J,con)
        if nargin==3
            con = spin_utils.get_default_convention();
        end
        spin_utils.error_check_spin(J);
        % following Kevin's conventions
        [jx,~,jz] = spin_utils.make_ang_mom(J,con);
        U = expm( 1i*(1-s)*jz*t )*expm( 1i*s*jx*jx*t/(2*J) );
    end

    function set_default_convention(val)
        spin_utils.get_default_convention(val);
    end

end
methods (Access=private,Static)
    function error_check_spin(J)
        dim = 2*J+1;
        if floor(dim)~=dim
            error('Spin must be half integer')
        end
    end

    function con = get_default_convention(nval)
        persistent val
        if isempty(val)
            val = 'standard';
        end
        if nargin==1
            if (~strcmp(nval,'standard'))&&(~strcmp(nval,'bgrape'))
                error('Spin convention not recognized')
            end
            val = nval;
        end
        con = val;
    end

    function scs = gen_scs_standard(n,J)
        % GEN_SCS  Generates Spin Coherent State Vector.
        %   scs = GEN_SCS(n,J) spin coherent state with total spin number J pointed in 
        %                      direction specified by unit vector n 
        %   standard basis state ordering
        spin_utils.error_check_spin(J);
        nn = 2*J; % dimension - 1 (not to be confused with n)

        phi = -atan2(n(2),n(1)); % azimuthal angle
        p = (-n(3)+1)/2; % stands in for altitude angle

        scs = zeros(nn+1,1);
        if n(3) == 1
            scs(1,1) = 1;
            return
        else
            scs(nn+1,1) = (p^(nn/2))*exp(1j*phi*J);  % the phase here is not necessary
            f = sqrt((1-p)/p)*exp(-1j*phi);
        end
        % scs(ii) = sqrt(binom(nn,ii-1,p))*exp(-1j*phi*(J-ii)) from ii = [1,nn+1]
        % efficiently calculate square root of binomial coefficients
        % with added azimuthal phase component
        for ii = 0:(nn-1)
            scs(nn-ii) = scs(nn+1-ii)*f*sqrt((nn-ii)/(ii+1.));
        end
    end
    function scs = gen_scs_bgrape(n,J)
        % GEN_SCS  Generates Spin Coherent State Vector.
        %   scs = GEN_SCS(n,J) spin coherent state with total spin number J pointed in 
        %                      direction specified by unit vector n 
        %   standard basis state ordering
        spin_utils.error_check_spin(J);
        nn = 2*J; % dimension - 1 (not to be confused with n)

        phi = atan2(n(2),n(1)); % azimuthal angle
        p = (-n(3)+1)/2; % stands in for altitude angle

        scs = zeros(nn+1,1);
        if n(3) == 1
            scs(end,1) = 1;
            return
        else
            scs(1,1) = (p^(nn/2))*exp(1j*phi*J);  % the phase here is not necessary
            f = sqrt((1-p)/p)*exp(-1j*phi);
        end
        % scs(ii) = sqrt(binom(nn,ii-1,p))*exp(-1j*phi*(J-ii)) from ii = [1,nn+1]
        % efficiently calculate square root of binomial coefficients
        % with added azimuthal phase component
        for ii = 0:(nn-1)
            scs(ii+2) = scs(ii+1)*f*sqrt((nn-ii)/(ii+1.));
        end
    end

end
end

