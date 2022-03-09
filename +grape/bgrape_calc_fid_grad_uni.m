function [ fid, dFid_j_k ] = bgrape_calc_fid_grad_uni( opt_params, control_fields )
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    timesteps = opt_params.timesteps;
    
    target_uni = opt_params.target_uni;
    subspace_proj = opt_params.subspace_proj;
    subspace_dim = opt_params.subspace_dim;
    
    opt_params.control_fields = control_fields;
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dUniT_k_j = zeros(16,16,3,timesteps);
    dFid_j_k = zeros(timesteps,3);
    
    proj_conj_target_uni = ctranspose( subspace_proj * target_uni * subspace_proj );
    proj_target_uni = subspace_proj * target_uni * subspace_proj;
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ uni_final, uniF_j, uniB_j, eigvec_hammy_j, eigval_hammy_j ] = grape.bgrape_calc_uni( opt_params );
    
    dUni_k_j = grape.bgrape_calc_uni_d(opt_params, eigvec_hammy_j, eigval_hammy_j);    
    
    for ss=1:3
        
        dUniT_k_j(:,:,ss,1) = uniB_j(:,:,2) * dUni_k_j(:,:,ss,1);
        dUniT_k_j(:,:,ss,timesteps) = dUni_k_j(:,:,ss,timesteps) * uniF_j(:,:,timesteps-1);
        
        for tt=2:timesteps-1
            dUniT_k_j(:,:,ss,tt) = uniB_j(:,:,tt+1) * dUni_k_j(:,:,ss,tt) * uniF_j(:,:,tt-1);
        end
        
    end
    
    for tt=1:timesteps
        for ss=1:3
                                                        
            proj_dUniT_j_k = subspace_proj * dUniT_k_j(:,:,ss,tt) * subspace_proj;
            proj_conj_uniT = ctranspose( subspace_proj * uni_final * subspace_proj );
            dFid_j_k(tt,ss) = (-1) * (1/subspace_dim^2) * real( grape.bgrape_trace_matmul(proj_conj_target_uni,proj_dUniT_j_k) ...
                                                                * grape.bgrape_trace_matmul(proj_target_uni,proj_conj_uniT)         );
       
        end
    end
    
    proj_total_uni = subspace_proj * uni_final * subspace_proj;
    fid = -1 * grape.bgrape_mat_fid(proj_total_uni, proj_target_uni, subspace_dim);
    
end

