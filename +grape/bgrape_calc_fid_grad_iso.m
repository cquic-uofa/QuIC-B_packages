function [ fid, dFid_j_k ] = bgrape_calc_fid_grad_iso( opt_params, control_fields )
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    timesteps = opt_params.timesteps;
    
    init_iso = opt_params.init_iso;
    target_iso = opt_params.target_iso;
    subspace_dim = opt_params.subspace_dim;
    
    opt_params.control_fields = control_fields;
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dUniT_k_j = zeros(16,16,3,timesteps);
    dFid_j_k = zeros(timesteps,3);
    
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

            dFid_j_k(tt,ss) = (-1)*(2/subspace_dim^2)*real( trace(ctranspose(target_iso)*dUniT_k_j(:,:,ss,tt)*init_iso) * ...
                                                            conj(trace(ctranspose(target_iso)*uni_final*init_iso))       );
        end
    end
    
    iso_final = uni_final*init_iso;
    fid = (-1) * grape.bgrape_mat_fid_iso(target_iso,iso_final,subspace_dim);
    
end

