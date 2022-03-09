function [ dW_wk ] = ngrape_calcRotd( opt_params, cfield_vec )

%%%%%
% ngrape_calcRotd.m
% 
% Exactly calculates the partial derivative in order to find the fidelity
% gradient for each element of the hermitian basis we're using (in this
% case, the Gell-Mann).
%
% 2018.09.11 v1.0 nkl - Streamlined and verified.
%%%%%

subspace_vec = opt_params.subspace_vec;
dim = length(subspace_vec); 

%%%%%

lambda_mat = grape.hermitian_basis_S( dim );
% lambda_mat = hermitian_basis_Sd( dim );

%%%%% 

[ ~, A ] = grape.makeCfieldRotMat( subspace_vec, cfield_vec );
[ eigvec_A, eigval_A ] = eig(A);

%%%%%
% construct the partial for each element of the basis

for kk = 1:(dim^2-1)
    
    temp_dW = zeros(dim,dim);
    
    lambda_mat_a = ctranspose(eigvec_A) * lambda_mat(:,:,kk) * eigvec_A;

    for ll = 1:dim
        for mm = 1:dim
            if (abs(eigval_A(ll,ll) - eigval_A(mm,mm))) < 1e-4
                f_l_m(ll,mm) = 1i*lambda_mat_a(ll,mm)*exp(1i*eigval_A(mm,mm));
            else
                f_l_m(ll,mm) = lambda_mat_a(ll,mm)*(exp(1i*eigval_A(ll,ll)) - exp(1i*eigval_A(mm,mm))) / ... 
                    ( eigval_A(ll,ll) - eigval_A(mm,mm));
            end
        end
    end

    temp_dW = eigvec_A * f_l_m * ctranspose(eigvec_A); 
                
   dW_wk(:,:,kk) =  temp_dW;

end

end