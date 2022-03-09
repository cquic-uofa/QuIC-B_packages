function [ infid ] = ngrape_matInfid( mat1, mat2, subspace_dim )

mat1_conj = ctranspose(mat1);

infid = 1 - (1/subspace_dim^2) * abs(grape.bgrape_trace_matmul(mat1_conj,mat2))^2;

end

