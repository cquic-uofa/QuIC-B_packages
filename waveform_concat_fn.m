function opt_params = waveform_concat_fn(steps)

    % expect steps to be of the form steps(ii).opt_params,steps(ii).n
    N = numel(steps);
    tot_time = 0;
    timesteps = 0;
    for ii = 1:N
        tot_time = tot_time + steps(ii).opt_params.tot_time * steps(ii).n;
        timesteps = timesteps + steps(ii).opt_params.timesteps * steps(ii).n;
    end

    control_fields = zeros(timesteps,3);
    offset = 1;
    for ii = 1:N
        n_ii = steps(ii).opt_params.timesteps;
        for jj = 1:steps(ii).n
            control_fields(offset:(offset+n_ii-1),:) = steps(ii).opt_params.control_fields;
            offset = offset + n_ii;
        end
    end

    opt_params = steps(1).opt_params;
    opt_params.timesteps = timesteps;
    opt_params.tot_time = tot_time;
    opt_params.control_fields = control_fields;
    opt_params.rf_wave = control_fields(:,1:2).';
    opt_params.mw_wave = control_fields(:,3).';
    opt_params.control_fields_final = control_fields;
    opt_params.points = timesteps;
    opt_params.uni_final = bgrape_calc_uni_final(opt_params);

end




function [ hammy_j ] = bgrape_calc_hammy( opt_params )
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    timesteps = opt_params.timesteps;
    
    hammy_zero = opt_params.hammy_zero;
    rf_bias = opt_params.rf_bias;
    rf_freq = opt_params.rf_freq;
    rf_amp_x = opt_params.rf_amp_x;
    rf_amp_y = opt_params.rf_amp_y;
    mw_amp = opt_params.mw_amp;
    rf_det = opt_params.rf_det;
    grel = opt_params.grel;
    fx4 = opt_params.fx4;
    fy4 = opt_params.fy4;
    fz4 = opt_params.fz4;
    fx3 = opt_params.fx3;
    fy3 = opt_params.fy3;
    fz3 = opt_params.fz3;
    mw_sx = opt_params.mw_sx;
    mw_sy = opt_params.mw_sy;
    
    phix = opt_params.control_fields(:,1);
    phiy = opt_params.control_fields(:,2);
    phimw = opt_params.control_fields(:,3);
    
    XX = opt_params.rwa_order_val;
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    hammy_j = zeros(16,16,timesteps);
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for tt=1:timesteps
        c_fx3 = ( ( (rf_amp_x/2)*cos(phix(tt))*grel*(1-((XX*rf_bias*(1+grel))/(2*rf_freq))) ) + ...
            ( XX*(rf_amp_x/2)*cos(phix(tt))*(rf_det/(2*rf_freq))*grel ) + ...
            ( (rf_amp_y/2)*sin(phiy(tt))*(-grel)*(1+((XX*rf_bias*(1+grel))/(2*rf_freq))) ) + ...
            ( XX*(rf_amp_y/2)*sin(phiy(tt))*(rf_det/(2*rf_freq))*(-grel) ) );
        c_fx4 = ( ( (rf_amp_x/2)*cos(phix(tt)) ) + ...
            ( XX*(rf_amp_x/2)*(rf_det/(2*rf_freq))*sin(phix(tt)) ) + ...
            ( (rf_amp_y/2)*sin(phiy(tt)) ) + ...
            ( XX*(rf_amp_y/2)*(rf_det/(2*rf_freq))*cos(phiy(tt)) ) );
        c_fy3 = ( ( (rf_amp_x/2)*sin(phix(tt))*grel*(1+((XX*rf_bias*(1+grel))/(2*rf_freq))) ) + ...
            ( XX*(rf_amp_x/2)*sin(phix(tt))*(rf_det/(2*rf_freq))*grel ) + ...
            ( (rf_amp_y/2)*cos(phiy(tt))*(grel)*(1-((XX*rf_bias*(1+grel))/(2*rf_freq))) ) + ...
            ( XX*(rf_amp_y/2)*cos(phiy(tt))*(rf_det/(2*rf_freq))*(-grel) ) );
        c_fy4 = ( ( (rf_amp_x/2)*(-sin(phix(tt))) ) + ...
            ( XX*(rf_amp_x/2)*(-rf_det/(2*rf_freq))*cos(phix(tt)) ) + ...
            ( (rf_amp_y/2)*cos(phiy(tt)) ) + ...
            ( XX*(rf_amp_y/2)*(rf_det/(2*rf_freq))*sin(phiy(tt)) ) );
        c_fz3 = XX*( (-1*(grel^2)/(16*rf_freq)) * ...
            ( ( (rf_amp_x^2)*(1-(2*cos(2*phix(tt)))) ) + ...
            ( (rf_amp_y^2)*(1-(2*cos(2*phiy(tt)))) ) + ...
            ( (-2)*rf_amp_x*rf_amp_y*sin( phix(tt) - phiy(tt) ) ) ) );
        c_fz4 = XX*( (1/(16*rf_freq)) * ...
            ( ( (rf_amp_x^2)*(1-(2*cos(2*phix(tt)))) ) + ...
            ( (rf_amp_y^2)*(1-(2*cos(2*phiy(tt)))) ) + ...
            ( 2*rf_amp_x*rf_amp_y*sin( phix(tt) - phiy(tt) ) ) ) );
        c_sx =  ( (mw_amp/2)*cos(phimw(tt)) );
        c_sy =  ( (mw_amp/2)*(-sin(phimw(tt))) );
        
        hammy_j(:,:,tt) =   ( hammy_zero + ...
                            (c_fx3 * fx3) + ...
                            (c_fx4 * fx4) + ...
                            (c_fy3 * fy3) + ...
                            (c_fy4 * fy4) + ...
                            (c_fz3 * fz3) + ...
                            (c_fz4 * fz4) + ...
                            (c_sx * mw_sx) + ...
                            (c_sy * mw_sy) );
    end
              
              
            
end

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
    
    hammy_j = bgrape_calc_hammy(opt_params);
    
    for tt = 1:timesteps
        [eigvec_hammy_j(:,:,tt),eigval_hammy_j(:,:,tt)] = eig(hammy_j(:,:,tt));
        exp_hammy(:,tt) = exp((-1i)*dt*diag(eigval_hammy_j(:,:,tt)));
        uni_j(:,:,tt) = eigvec_hammy_j(:,:,tt)*diag(exp_hammy(:,tt))*ctranspose(eigvec_hammy_j(:,:,tt));
    end
    
    %initialize j=1 forward uni and j=timesteps backward uni
    uniF_j(:,:,1) = uni_j(:,:,1);
%    uniB_j(:,:,timesteps) = uni_j(:,:,timesteps);
    
    %calculate each total forward unitary
    for tt=2:timesteps 
        uniF_j(:,:,tt) = uni_j(:,:,tt)*uniF_j(:,:,tt-1);
    end         
    
    %calculate each total backward unitary
%    for tt=timesteps-1:-1:1
%        uniB_j(:,:,tt) = uniB_j(:,:,tt+1)*uni_j(:,:,tt);
%    end
    
    uni_final = uniF_j(:,:,timesteps);
end

