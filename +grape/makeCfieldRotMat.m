function [ W, A ] = makeCfieldRotMat( subspace_vec, cfield_vec )

%%%%%
% makeCfieldRotMat.m
%
% Makes W to rotate target_uni into a new basis for rot_search. This is
% based on the search parameters {w_(j)} being scalars multiplied by a
% matrix basis set {\Lamda_(j)} - in our case, the Generalized Gell-Mann.
%
% 2018.09.11 v1.0 nkl - Updated name and certified for use.
% 2018.09.06 v0.1 nkl - First version. Adapted from Pablo Poggi's writeup
%                       and using code from the ST/PT project for GGM.
%%%%%

dim = length( subspace_vec );
% subspace_vec = opt_params.subspace_vec;

%%%%%

lambda_mat = grape.hermitian_basis_S( dim );
% lambda_mat = hermitian_basis_Sd( dim );

%%%%%
% generate A from scalars times basis lambda

A = zeros(dim,dim);

for ii = 1:(dim^2-1)
    A = A + cfield_vec(ii) * lambda_mat(:,:,ii);
end

%%%%%
% make unitary matrix W from exponentiating A
W = expm(1i*A);
    
end