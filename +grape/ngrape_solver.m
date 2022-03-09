function [ opt_params ] = ngrape_solver( opt_params )

%%%%%
% ngrape_solver.m
%
% Routine for executing rotating basis search for waveforms. Current does
% not have capability to do isometries or robust searches.
%
% 2018.10.03 v1.0 nkl - Moving this to version 1.0. Added gradient capabilities.
% 2018.09.11 v0.5 nkl - Multiple changes, first working version.
% 2018.09.06 v0.1 nkl - First version, adapted from bgrape_solver.m
%%%%%

subspace_dim = opt_params.subspace_dim;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ( isfield(opt_params,'TolFun') )
    tolfun = opt_params.TolFun;
else
    tolfun = 1e-6;
end

if ( isfield(opt_params,'TolX') )
    tolx = opt_params.TolX;
else
    tolx = 1e-6;
end

problem.options = optimset(...
    'TolX',             tolx,...
    'TolFun',           tolfun,...
    'DerivativeCheck',  'off',...
    'FinDiffType',      'central',...    
    'GradObj',          'on',...
    'LargeScale',       'off', ...
    'Display',          'off', ...
    'MaxFunEvals',      10^6, ...
    'MaxIter',          10^6, ...
    'OutputFcn',        @(x, optimValues, state) grape.ngrape_searchStopFn(x, optimValues, state, opt_params.infid_stop) );
problem.solver = 'fminunc';

% if ( opt_params.iso_or_uni == 'iso')
%     if ( (opt_params.rf_det_error<0.01) & (opt_params.mw_amp_error<0.01) )
%         problem.objective = @(x)bgrape_calc_fid_grad_iso(opt_params,x);
%         %fprintf('no grid \n');
%     elseif ( (opt_params.rf_det_error>0.01) & (opt_params.mw_amp_error<0.01) )
%         problem.objective = @(x)bgrape_calc_fid_grad_gridrf_iso(opt_params,x);
%         %fprintf('rf grid \n');
%     elseif ( (opt_params.rf_det_error>0.01) & (opt_params.mw_amp_error>0.01) )
%         problem.objective = @(x)bgrape_calc_fid_grad_gridrfmw_iso(opt_params,x);
%         %fprintf('rf and uw grid \n');
%     else
%         fprintf('bad inhomo errors.\n');
%     end
% elseif ( opt_params.iso_or_uni == 'uni')
    if ( (opt_params.rf_det_error<0.01) && (opt_params.mw_amp_error<0.01) && (opt_params.rf_amp_error<0.01) )
        problem.objective = @(x) grape.ngrape_calcInfidGradUniRot(opt_params,x);
        fprintf('no grid \n');
    elseif ( (opt_params.rf_det_error>0.01) && (opt_params.mw_amp_error<0.01) && (opt_params.rf_amp_error>0.01) )
        problem.objective = @(x) grape.ngrape_calcInfidGradUniRot_rfBiasrfAmp(opt_params,x);
        fprintf('rfAmp and rf grid \n');
    elseif ( (opt_params.rf_det_error<0.01) && (opt_params.mw_amp_error<0.01) && (opt_params.rf_amp_error>0.01) )
        problem.objective = @(x) grape.ngrape_calcInfidGradUniRot_rfAmp(opt_params,x);
        fprintf('rfAmp grid \n');
    elseif ( (opt_params.rf_det_error>0.01) && (opt_params.mw_amp_error<0.01) )
        problem.objective = @(x) grape.ngrape_calcInfidGradUniRot_rfDet(opt_params,x);
        fprintf('rf grid \n');
    elseif ( (opt_params.rf_det_error<0.01) && (opt_params.mw_amp_error>0.01) )
        problem.objective = @(x) grape.ngrape_calcInfidGradUniRot_mwAmp(opt_params,x);
        fprintf('uw grid \n');
    elseif ( (opt_params.rf_det_error>0.01) && (opt_params.mw_amp_error>0.01) )
        problem.objective = @(x) grape.ngrape_calcInfidGradUniRot_rfDetmwAmp(opt_params,x);
        fprintf('rf and uw grid \n');
    else
        fprintf('bad inhomo errors.\n');
    end
% else
%     fprintf('bad iso_or_uni.\n');
% end

%%%%%
% initiate the search using the desired optimizer
search_attempts = 0;
time_vec = clock;
infid_final = 1;

while ( (infid_final > opt_params.infid_stop) && (search_attempts < opt_params.max_seeds) )

    search_attempts = search_attempts + 1;
    
    rng(opt_params.job_num*10+time_vec(6)+search_attempts);
    problem.x0 = 2*pi*rand(3*opt_params.timesteps,1);
%     problem.x0 = vertcat(problem.x0, ones(subspace_dim^2-1,1)*0.0001);
    problem.x0 = vertcat(problem.x0, zeros(subspace_dim^2-1,1));    
    [control_fields_final, infid_final, exitflag, output, grad_final] = fminunc(problem);
%    [control_fields_final, fid_final, exitflag, output] = fminsearch(problem);

end

%%%%%
% load final fields into opt_params and pass back to driver
opt_params.control_fields_final(:,1) = control_fields_final(1:opt_params.timesteps);
opt_params.control_fields_final(:,2) = control_fields_final(opt_params.timesteps+1:2*opt_params.timesteps);
opt_params.control_fields_final(:,3) = control_fields_final(2*opt_params.timesteps+1:3*opt_params.timesteps);
opt_params.infid_search = infid_final;
opt_params.search_attempts = search_attempts;

% necessary for making final unitaries and testing
opt_params.control_fields(:,1) = control_fields_final(1:opt_params.timesteps);
opt_params.control_fields(:,2) = control_fields_final(opt_params.timesteps+1:2*opt_params.timesteps);
opt_params.control_fields(:,3) = control_fields_final(2*opt_params.timesteps+1:3*opt_params.timesteps);
opt_params.uni_final = bgrape_calc_uni_final(opt_params);

opt_params.rot_series_final = control_fields_final(opt_params.timesteps*3+1:end);
opt_params.rot_map = makeCfieldRotMat( opt_params.subspace_vec, opt_params.rot_series_final );

% if ( opt_params.iso_or_uni == 'iso')
%     opt_params.iso_final = opt_params.uni_final*opt_params.init_iso;
%     opt_params.fid_iso = bgrape_mat_fid_iso(opt_params.target_iso,opt_params.iso_final,subspace_dim);
% else
    proj_target_uni = opt_params.subspace_proj * opt_params.rot_map * opt_params.target_uni * ctranspose(opt_params.rot_map) * opt_params.subspace_proj;
    proj_total_uni = opt_params.subspace_proj * opt_params.uni_final * opt_params.subspace_proj;
    opt_params.fid_center = bgrape_mat_fid(proj_total_uni, proj_target_uni, subspace_dim);
% end
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

