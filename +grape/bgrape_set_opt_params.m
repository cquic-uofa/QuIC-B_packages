function [ opt_params ] = bgrape_set_opt_params( opt_params )
    
    carlostobrianperm = [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0;...
                         0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0;...
                         0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0;...
                         0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0;...
                         0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0;...
                         0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0;...
                         0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0;...
                         0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
                         1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
                         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1;...
                         0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0;...
                         0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0;...
                         0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0;...
                         0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0;...
                         0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0;...
                         0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0;...
                         ];
    
    fup = 4;
    fdown = 3;

    dim = 2*(fup+fdown+1);
    dim_up = 2*fup+1;
    dim_down = 2*fdown+1;
    
    if strcmp(opt_params.iso_or_uni,'uni')
        subspace_proj = grape.bgrape_make_proj(opt_params.subspace_vec,16);
        subspace_dim = length(opt_params.subspace_vec);
        
        opt_params.subspace_proj = subspace_proj;
        opt_params.subspace_dim = subspace_dim;
    end
     
    if ( isfield(opt_params,'rwa_order') )
        if (opt_params.rwa_order == 1)
            opt_params.rwa_order_val = 0;
            %fprintf('RWA order is 1. \n');
        else
            opt_params.rwa_order_val = 1;
        end
    else
        opt_params.rwa_order = 2;
        opt_params.rwa_order_val = 1;
    end
    
    if ( ~isfield(opt_params,'rf_det') )
        opt_params.rf_det = 0;
    end
    
    opt_params.timesteps = round(opt_params.tot_time / opt_params.samp_time);

    upang = grape.bgrape_make_ang_mom(fup);
    downang = grape.bgrape_make_ang_mom(fdown);
    rf_freq = opt_params.rf_freq;
    rf_amp_x = opt_params.rf_amp_x;
    rf_amp_y = opt_params.rf_amp_y;
    mw_amp = opt_params.mw_amp;
    rf_det = opt_params.rf_det;
    
    rf_bias = rf_freq - rf_det;
    grel = -1.0032;
    hf_freq = 2*pi*(9.19263e9);
    freq_44_33_0det = hf_freq - (7*grel*rf_freq^2*(1/hf_freq)) + ((4-3*grel)*rf_freq);
    mw_det = freq_44_33_0det - ( hf_freq - (7*grel*rf_bias^2*(1/hf_freq)) + ((4-3*grel)*rf_bias) );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%MAKE ALL OF THE OPERATORS IN THE HAMILTONIAN
    %%% Use the standard convention, (4,3,...,-3,-4)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Make the 16x16 angular momentum operators
    fx_up = [upang.jx,zeros(dim_up,dim_down);
        zeros(dim_down,dim_up),zeros(dim_down,dim_down)];
    fy_up = -[upang.jy,zeros(dim_up,dim_down);
        zeros(dim_down,dim_up),zeros(dim_down,dim_down)];
    fz_up = -[upang.jz,zeros(dim_up,dim_down);
        zeros(dim_down,dim_up),zeros(dim_down,dim_down)];
    fx_down = [zeros(dim_up,dim_up),zeros(dim_up,dim_down);
        zeros(dim_down,dim_up),downang.jx];
    fy_down = -[zeros(dim_up,dim_up),zeros(dim_up,dim_down);
        zeros(dim_down,dim_up),downang.jy];
    fz_down = -[zeros(dim_up,dim_up),zeros(dim_up,dim_down);
        zeros(dim_down,dim_up),downang.jz];

    %Make the 16x16 microwave operators
    mw_sigma_x = zeros(dim,dim); mw_sigma_y = zeros(dim,dim);
    up_proj = zeros(dim,dim); down_proj = zeros(dim,dim);
    mw_sigma_x(1,10) = 1; mw_sigma_x(10,1) = 1;
    mw_sigma_y(1,10) = -1i; mw_sigma_y(10,1) = 1i;
    for jj = 1:9
        up_proj(jj,jj) = 1;
    end
    for jj = 10:16
        down_proj(jj,jj) = 1;
    end

    
    ACZ = zeros(16);
    for m = 2:-1:-3
        V3j = zeros(16,1);
        V4k = zeros(16,1);
        jjj = m+13;
        kkk = m+6;
        V3j(jjj) = 1;
        
        V4k(kkk) = 1;
        ACZ = ACZ+(V3j*V3j'-V4k*V4k')*(abs(grape.bgrape_ClebschGordan(3,1,4,m,1,m+1)))^2/(-1*(m-3)); %minus sign corrected 4 June 2012
    end
    ACZ = (mw_amp)^2/(8*rf_bias)*ACZ;      
        
    hammy_zero = ( ( (3/2)*rf_bias*(1+grel) ) - ( (25/2)*grel*rf_bias^2*(1/hf_freq) ) - ( (1/2)*(mw_det-7*rf_det) ) ) * (up_proj - down_proj) + ...
                 ( rf_bias*(1+grel)*fz_down ) + ...
                 ( grel*rf_bias^2*(1/hf_freq)*(fz_up*fz_up-fz_down*fz_down) ) + ...
                 ( (-1*rf_det*(fz_up+grel*fz_down) ) ) + ...
                 ( carlostobrianperm * ACZ * carlostobrianperm );


    opt_params.fx4 = fx_up; 
    opt_params.fy4 = fy_up; 
    opt_params.fz4 = fz_up; 
    opt_params.fx3 = fx_down; 
    opt_params.fy3 = fy_down;
    opt_params.fz3 = fz_down;
    opt_params.fx = fx_up + grel*fx_down; 
    opt_params.fy = fy_up + grel*fy_down; 
    opt_params.fz = fz_up + grel*fz_down; 
    opt_params.mw_sx = mw_sigma_x;
    opt_params.mw_sy = mw_sigma_y;
    opt_params.up_proj = up_proj; 
    opt_params.down_proj = down_proj;
    opt_params.hammy_ACZ = ( carlostobrianperm * ACZ * carlostobrianperm );
    opt_params.hammy_zero = hammy_zero;
    opt_params.grel = grel; 
    opt_params.hf_freq = hf_freq;
    opt_params.freq_44_33_0det = freq_44_33_0det;
    opt_params.rf_bias = rf_bias;
    opt_params.mw_det = mw_det;

end
