classdef ST_cvx

methods (Static)

    

    function POVM = get_MUB_POVM(options)
        arguments
            options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
            % leave template as required argument for now
            options.template (1,1) string = "";
            options.conjugate (1,1) logical = true;
        end

        if options.template == ""
            root = getenv("QuICMATROOT");
            MUB_root = fullfile(root,"QuIC-B_packages","MUB");
            % this allows basis files to have different names
            options.template = fullfile(MUB_root,"*basis_%d.mat");

        end
        
        dim = 2*options.J+1;
        POVM = zeros(dim*(dim+1),dim^2); % superoperator for use in reconstruction
        
        for ii = 1:(dim+1)

            [path,name,ext] = fileparts(options.template);
            % sprintf can't deal with slashes in a string, fileparts removes the slash so the next line works
            MUB_file = dir(fullfile(path,strcat(sprintf(name,ii),ext)));
            data = load(fullfile(MUB_file.folder,MUB_file.name));
            basis = data.opt_params.target_uni;
            for jj = 1:dim
                if options.conjugate
                    state = basis(jj,:); % target is already conjugated
                    POVM((ii-1)*dim+jj,:) = super_op.Op2DVec(state'*state);
                else
                    state = basis(:,jj); % target is not conjugated
                    POVM((ii-1)*dim+jj,:) = super_op.Op2DVec(state*state');
                end
            end
            
        end
        POVM = POVM/(dim+1); % Σ(POVM) = I
    end

    function r = get_MUB_meas(options)
        arguments
            options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
            options.template (1,1) string;
        end
        dim = 2*options.J+1;

        r = zeros(dim*(dim+1),1);
        for ii = 1:(dim+1)
            [path,name,ext] = fileparts(options.template);
            fname = fullfile(path,strcat(sprintf(name,ii),ext));
            solution = load(fname);
            r(  (1:dim) + (ii-1)*dim ) = solution.populations;
        end
        r = r/(dim+1); % to be consistent with POVM definition

    end

    function [rho,status] = solve_ls(A,M,options)
        arguments
            A (:,:) double % operators
            M (:,1) double % measurements
            options.tr_rho (1,1) double = 1;
            options.dim (1,1) double = 16;
        end


        [d1,d2] = size(A);
        assert(d1==length(M),"Operator map length mismatch")
        assert(options.dim^2==d2,"Operator dimension mismatch")
        dim = options.dim;

        cvx_clear
        cvx_begin quiet
            variable rho(dim,dim) complex
            x = rho(:);
            minimize( norm( A*x - M , 2 ) );
            subject to
                rho == hermitian_semidefinite(options.dim);
                trace(rho) == options.tr_rho;
        cvx_end
    
        rho = full(rho); 
        status = cvx_status;

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