function [ infid, dFid_j_k ] = ngrape_calcInfidGradUniRot( opt_params, control_fields )

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    timesteps = opt_params.timesteps;

    subspace_proj = opt_params.subspace_proj;
    subspace_dim = opt_params.subspace_dim;
    
    opt_params.control_fields(:,1) = control_fields(1:timesteps);
    opt_params.control_fields(:,2) = control_fields(timesteps+1:2*timesteps);
    opt_params.control_fields(:,3) = control_fields(2*timesteps+1:3*timesteps);
    opt_params.rot_mat = grape.makeCfieldRotMat(  opt_params.subspace_vec, control_fields(timesteps*3+1:end) );
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    target_rot_mat = opt_params.rot_mat;
    target_uni_bare = opt_params.target_uni;
% Previous error was due to the next line - wrong basis transformation wrt
% derivation.
%     target_uni = ctranspose(target_rot_mat)* target_uni_bare * target_rot_mat;
    target_uni = target_rot_mat* target_uni_bare * ctranspose(target_rot_mat);
    
    dUniT_k_j = zeros(16,16,3,timesteps);
    dFid_j_k = zeros(3*timesteps+(subspace_dim^2-1),1);
    
    proj_conj_target_uni = ctranspose( subspace_proj * target_uni * subspace_proj );
    proj_target_uni = subspace_proj * target_uni * subspace_proj; 
    
    conj_target_uni_bare = ctranspose( target_uni_bare );
    conj_target_rot_mat = ctranspose( target_rot_mat );
    
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
    
    proj_uniT = subspace_proj * uni_final * subspace_proj;
    proj_conj_uniT = ctranspose( subspace_proj * uni_final * subspace_proj );

    uniT = uni_final;
    conj_uniT = ctranspose( uni_final );
    
    for tt=1:3*timesteps
        
            rr = mod(tt,timesteps);
            ss = ceil(tt/timesteps);         
            if rr == 0
                proj_dUniT_j_k = subspace_proj * dUniT_k_j(:,:,ss,timesteps) * subspace_proj;   
            else
                proj_dUniT_j_k = subspace_proj * dUniT_k_j(:,:,ss,rr) * subspace_proj; 
            end       
            dFid_j_k(tt) = (-1) * (1/subspace_dim^2) * real( grape.bgrape_trace_matmul(proj_conj_target_uni,proj_dUniT_j_k) ...
                                                                * grape.bgrape_trace_matmul(proj_target_uni,proj_conj_uniT)         );
    end
    
    dW_wk = grape.ngrape_calcRotd( opt_params, control_fields(timesteps*3+1:end) );
    
    for uu=1:(subspace_dim^2 - 1)
        
        conj_dUniTarg_k = dW_wk(:,:,uu) * conj_target_uni_bare * conj_target_rot_mat + target_rot_mat * conj_target_uni_bare * ctranspose( dW_wk(:,:,uu) );
        proj_conj_dUniTarg_k = subspace_proj * conj_dUniTarg_k * subspace_proj;
        dFid_j_k(3*timesteps+uu) = (-1) * (1/subspace_dim^2) * real( grape.bgrape_trace_matmul(proj_uniT,proj_conj_dUniTarg_k) ...
                                                           * grape.bgrape_trace_matmul(proj_target_uni,proj_conj_uniT)         );
        
    end

    infid = grape.ngrape_matInfid(proj_uniT, proj_target_uni, subspace_dim);

end

