function [ infid, dFid_j_k ] = ngrape_calcInfidGradUniRot_mwAmp( opt_params, control_fields )
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    timesteps = opt_params.timesteps;
    mw_amp = opt_params.mw_amp;
    mw_amp_error = opt_params.mw_amp_error;

    infid = 0;
    infid_temp = 1;
    dFid_j_k = zeros(size(control_fields,1),1);
    dFid_j_k_temp = zeros(size(control_fields,1),1);

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    opt_params.mw_amp = mw_amp + mw_amp_error;
    opt_params = grape.bgrape_set_opt_params(opt_params);
    [infid_temp,dFid_j_k_temp] = grape.ngrape_calcInfidGradUniRot(opt_params, control_fields);
    infid = infid + infid_temp;
    dFid_j_k = dFid_j_k + dFid_j_k_temp;

    opt_params.mw_amp = mw_amp - mw_amp_error;
    opt_params = grape.bgrape_set_opt_params(opt_params);
    [infid_temp,dFid_j_k_temp] = grape.ngrape_calcInfidGradUniRot(opt_params, control_fields);
    infid = infid + infid_temp;
    dFid_j_k = dFid_j_k + dFid_j_k_temp;

    infid = infid/2;
    dFid_j_k = dFid_j_k/2;

end

