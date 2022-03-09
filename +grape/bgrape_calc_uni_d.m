function [ dUni_k_j ] = bgrape_calc_uni_d( opt_params, eigvec_hammy_j, eigval_hammy_j )

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dt = opt_params.samp_time;
    timesteps = opt_params.timesteps;
    
    fx4 = opt_params.fx4;
    fy4 = opt_params.fy4;
    fz4 = opt_params.fz4;
    fx3 = opt_params.fx3;
    fy3 = opt_params.fy3;
    fz3 = opt_params.fz3;
    mw_sx = opt_params.mw_sx;
    mw_sy = opt_params.mw_sy;
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    exp_eig_factor = complex(zeros(16,16));
    dUni_k_j = complex(zeros(16,16,3,timesteps));
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [hammy_d] = grape.bgrape_calc_hammy_d(opt_params);
    
    for tt = 1:timesteps
        
        D = diag(eigval_hammy_j(:,:,tt));
        V = eigvec_hammy_j(:,:,tt);
        ct_V = ctranspose(V);

        for aa=1:16
            
            exp_eig_factor(aa,aa) = -(1i)*dt*exp(-(1i)*D(aa)*dt); %degenerate so use eq 3.10
            
            for bb=aa+1:16 %not degenerate so use eq 3.9
                exp_eig_factor(aa,bb) = ( exp(-(1i)*D(aa)*dt) - exp(-(1i)*D(bb)*dt) ) / ( D(aa)-D(bb) );
                exp_eig_factor(bb,aa) = exp_eig_factor(aa,bb);
            end
        end        
        
        dUni_op.fx3 = V * ((ct_V * fx3 * V).*exp_eig_factor) *  ct_V;
        dUni_op.fy3 = V * ((ct_V * fy3 * V).*exp_eig_factor) *  ct_V;
        dUni_op.fz3 = V * ((ct_V * fz3 * V).*exp_eig_factor) *  ct_V;
        dUni_op.fx4 = V * ((ct_V * fx4 * V).*exp_eig_factor) *  ct_V;
        dUni_op.fy4 = V * ((ct_V * fy4 * V).*exp_eig_factor) *  ct_V;
        dUni_op.fz4 = V * ((ct_V * fz4 * V).*exp_eig_factor) *  ct_V;
        dUni_op.mw_sx = V * ((ct_V * mw_sx * V).*exp_eig_factor) *  ct_V;
        dUni_op.mw_sy = V * ((ct_V * mw_sy * V).*exp_eig_factor) *  ct_V;
        
        dUni_k_j(:,:,1,tt) = ( (hammy_d(1,tt)*dUni_op.fx3) + ...
                               (hammy_d(2,tt)*dUni_op.fx4) + ...
                               (hammy_d(3,tt)*dUni_op.fy3) + ...
                               (hammy_d(4,tt)*dUni_op.fy4) + ...
                               (hammy_d(5,tt)*dUni_op.fz3) + ...
                               (hammy_d(6,tt)*dUni_op.fz4) );
        
        dUni_k_j(:,:,2,tt) = ( (hammy_d(7,tt)*dUni_op.fx3) + ...
                               (hammy_d(8,tt)*dUni_op.fx4) + ...
                               (hammy_d(9,tt)*dUni_op.fy3) + ...
                               (hammy_d(10,tt)*dUni_op.fy4) + ...
                               (hammy_d(11,tt)*dUni_op.fz3) + ...
                               (hammy_d(12,tt)*dUni_op.fz4) );                  
        
        dUni_k_j(:,:,3,tt) = ( (hammy_d(13,tt)*dUni_op.mw_sx) + ...
                               (hammy_d(14,tt)*dUni_op.mw_sy) );
    end
end

