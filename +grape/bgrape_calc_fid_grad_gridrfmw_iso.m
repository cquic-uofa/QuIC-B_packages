function [ fid, dFid_j_k ] = bgrape_calc_fid_grad_gridrfmw_iso( opt_params, control_fields )
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt_params.control_fields = control_fields;
timesteps = opt_params.timesteps;
rf_det_error = opt_params.rf_det_error;
mw_amp_error = opt_params.mw_amp_error;
mw_amp = opt_params.mw_amp;

fid = 0;
dFid_j_k = zeros(timesteps,3);
fid_temp = 0;
dFid_j_k_temp = zeros(timesteps,3);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt_params.rf_det = rf_det_error;
opt_params.mw_amp = mw_amp + mw_amp_error;
opt_params = grape.bgrape_set_opt_params(opt_params);
[fid_temp, dFid_j_k_temp] = grape.bgrape_calc_fid_grad_iso(opt_params, control_fields);
fid = fid + fid_temp;
dFid_j_k = dFid_j_k + dFid_j_k_temp;

opt_params.rf_det = rf_det_error;
opt_params.mw_amp = mw_amp - mw_amp_error;
opt_params = grape.bgrape_set_opt_params(opt_params);
[fid_temp, dFid_j_k_temp] = grape.bgrape_calc_fid_grad_iso(opt_params, control_fields);
fid = fid + fid_temp;
dFid_j_k = dFid_j_k + dFid_j_k_temp;

opt_params.rf_det = -rf_det_error;
opt_params.mw_amp = mw_amp + mw_amp_error;
opt_params = grape.bgrape_set_opt_params(opt_params);
[fid_temp, dFid_j_k_temp] = grape.bgrape_calc_fid_grad_iso(opt_params, control_fields);
fid = fid + fid_temp;
dFid_j_k = dFid_j_k + dFid_j_k_temp;

opt_params.rf_det = -rf_det_error;
opt_params.mw_amp = mw_amp - mw_amp_error;
opt_params = grape.bgrape_set_opt_params(opt_params);
[fid_temp, dFid_j_k_temp] = grape.bgrape_calc_fid_grad_iso(opt_params, control_fields);
fid = fid + fid_temp;
dFid_j_k = dFid_j_k + dFid_j_k_temp;

fid = fid/4;
dFid_j_k = dFid_j_k/4;


end

