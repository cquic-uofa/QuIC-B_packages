function [rho,status,EP] = solve_ls(A,M,options)
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
    EP = norm(A*rho(:)-M,2);

    status = cvx_status;
    cvx_clear
end