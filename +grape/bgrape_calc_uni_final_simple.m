function [ uni_final ] = bgrape_calc_uni_final( opt_params )

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dt = opt_params.samp_time;
    timesteps = opt_params.timesteps;
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    uniF_j = zeros(16,16,timesteps);
%    uniB_j = zeros(16,16,timesteps);
    uni_j = zeros(16,16,timesteps);
    eigvec_hammy_j = zeros(16,16,timesteps);
    eigval_hammy_j = zeros(16,16,timesteps);
    exp_hammy = zeros(16,timesteps);
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %control_fields(timestepL,1)
    %calculate propagator for each timestep
    
    hammy_j = grape.bgrape_calc_hammy(opt_params);
    
    uni_final = eye(16); 
    
    for tt = 1:timesteps
        [eigvec_hammy_j(:,:,tt),eigval_hammy_j(:,:,tt)] = eig(hammy_j(:,:,tt));
        exp_hammy(:,tt) = exp((-1i)*dt*diag(eigval_hammy_j(:,:,tt)));
        uni_final = eigvec_hammy_j(:,:,tt)*diag(exp_hammy(:,tt))*ctranspose(eigvec_hammy_j(:,:,tt)) * uni_final;
    end
    
%     %initialize j=1 forward uni and j=timesteps backward uni
%     uniF_j(:,:,1) = uni_j(:,:,1);
% %    uniB_j(:,:,timesteps) = uni_j(:,:,timesteps);
%     
%     %calculate each total forward unitary
%     for tt=2:timesteps 
%         uniF_j(:,:,tt) = uni_j(:,:,tt)*uniF_j(:,:,tt-1);
%     end         
%     
%     %calculate each total backward unitary
% %    for tt=timesteps-1:-1:1
% %        uniB_j(:,:,tt) = uniB_j(:,:,tt+1)*uni_j(:,:,tt);
% %    end
%     
%     uni_final = uniF_j(:,:,timesteps);
end

