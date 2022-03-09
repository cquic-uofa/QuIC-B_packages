function [ infid, dFid_j_k ] = ngrape_calcInfidGradUniRot_rfAmp( opt_params, control_fields )
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     opt_params.control_fields = control_fields;
    timesteps = opt_params.timesteps;
    rf_amp_x = opt_params.rf_amp_x;
    rf_amp_y = opt_params.rf_amp_y;
    rf_amp_err = opt_params.rf_amp_error;

    infid = 0;
    infid_temp = 1;
    dFid_j_k = zeros(size(control_fields,1),1);
    dFid_j_k_temp = zeros(size(control_fields,1),1);
    

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    opt_params.rf_amp_x = rf_amp_x + rf_amp_err;
    opt_params.rf_amp_y = rf_amp_y + rf_amp_err;
    opt_params = grape.bgrape_set_opt_params(opt_params);
    [infid_temp,dFid_j_k_temp] = grape.ngrape_calcInfidGradUniRot(opt_params, control_fields);
    infid = infid + infid_temp;
    dFid_j_k = dFid_j_k + dFid_j_k_temp;
    
    opt_params.rf_amp_x = rf_amp_x + rf_amp_err;
    opt_params.rf_amp_y = rf_amp_y - rf_amp_err;
    opt_params = grape.bgrape_set_opt_params(opt_params);
    [infid_temp,dFid_j_k_temp] = grape.ngrape_calcInfidGradUniRot(opt_params, control_fields);
    infid = infid + infid_temp;
    dFid_j_k = dFid_j_k + dFid_j_k_temp;

    opt_params.rf_amp_x = rf_amp_x - rf_amp_err;
    opt_params.rf_amp_y = rf_amp_y + rf_amp_err;
    opt_params = grape.bgrape_set_opt_params(opt_params);
    [infid_temp,dFid_j_k_temp] = grape.ngrape_calcInfidGradUniRot(opt_params, control_fields);
    infid = infid + infid_temp;
    dFid_j_k = dFid_j_k + dFid_j_k_temp;
    
    opt_params.rf_amp_x = rf_amp_x - rf_amp_err;
    opt_params.rf_amp_y = rf_amp_y - rf_amp_err;
    opt_params = grape.bgrape_set_opt_params(opt_params);
    [infid_temp,dFid_j_k_temp] = grape.ngrape_calcInfidGradUniRot(opt_params, control_fields);
    infid = infid + infid_temp;
    dFid_j_k = dFid_j_k + dFid_j_k_temp;

    infid = infid/4;
    dFid_j_k = dFid_j_k/4;
    
    opt_params.rf_amp_x = rf_amp_x;
    opt_params.rf_amp_y = rf_amp_y;
    
end

