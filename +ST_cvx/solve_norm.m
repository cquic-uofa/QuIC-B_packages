function [rho,status,EP_fin] = solve_norm(A,M,EP,options)
    arguments
        A (:,:) double % operators
        M (:,1) double % measurements
        EP (1,1) double % error constraint
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
        minimize( norm(x,2) );
        subject to
            rho == hermitian_semidefinite(options.dim);
            trace(rho) == options.tr_rho;
            norm( A*x - M , 2 ) <= EP;
    cvx_end
    rho = full(rho); 
    EP_fin = norm( A*rho(:)-M,2 );
    status = cvx_status;
    cvx_clear
end