classdef ST_cvx

methods (Static)

    function M = get_MUB_POVM(options)
        arguments
            options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
            % leave template as required argument for now
            options.template (1,1) string % = "workspace/targets/MUB_dim_16_ind_%d.mat";
        end
         
        dim = 2*options.J+1;
        M = zeros(dim^2,(dim+1)*dim); % superoperator for use in reconstruction

        for ii = 1:(dim+1)
            data = load(sprintf(options.template,ii));
            basis = data.target;
            for jj = 1:dim
                state = basis(:,jj);
                M((ii-1)*dim+jj,:) = super_op.Op2DVec(state*state');
            end

        end
    end

    function r = get_MUB_meas(options)
        arguments
            options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
            options.template (1,1) string;
        end
        dim = 2*options.J+1;

        r = zeros(dim*(dim+1),1);
        for ii = 1:(dim+1)
            solution = load(sprintf(options.template,ii));
            r(  (1:dim) + (ii-1)*dim ) = solution.populations;
        end

    end

    function [rho,status] = solve_ls(POVM,meas,options)
        arguments
            POVM (:,:) double
            meas (:,1) double
            options.tr_rho (1,1) double = 1;
            options.dim (1,1) int32 = 16;
            options.template (1,1) string;
        end


        [d1,d2] = size(POVM);
        assert(d2==length(meas),"POVM measurement length mismatch")
        assert(options.dim^2==d1,"Operator dimension mismatch")

        cvx_clear
        cvx_begin quiet
            variable rho(options.dim,options.dim) complex
            x = rho(:);
            minimize( norm( POVM*x - meas , 2 ) );
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