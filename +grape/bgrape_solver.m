function [ opt_params ] = bgrape_solver( opt_params )

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
    'Display',          'iter', ...
    'MaxFunEvals',      10^6, ...
    'MaxIter',          10^6, ...
    'OutputFcn',        @(x, optimValues, state) grape.bgrape_searchStopFn(x, optimValues, state, opt_params.fid_stop) );
problem.solver = 'fminunc';

if ( opt_params.iso_or_uni == 'iso')
    if ( (opt_params.rf_det_error<0.01) & (opt_params.mw_amp_error<0.01) )
        problem.objective = @(x) grape.bgrape_calc_fid_grad_iso(opt_params,x);
        %fprintf('no grid \n');
    elseif ( (opt_params.rf_det_error>0.01) & (opt_params.mw_amp_error<0.01) )
        problem.objective = @(x) grape.bgrape_calc_fid_grad_gridrf_iso(opt_params,x);
        %fprintf('rf grid \n');
    elseif ( (opt_params.rf_det_error>0.01) & (opt_params.mw_amp_error>0.01) )
        problem.objective = @(x) grape.bgrape_calc_fid_grad_gridrfmw_iso(opt_params,x);
        %fprintf('rf and uw grid \n');
    else
        fprintf('bad inhomo errors.\n');
    end
elseif ( opt_params.iso_or_uni == 'uni')
    if ( (opt_params.rf_det_error<0.01) & (opt_params.mw_amp_error<0.01) )
        problem.objective = @(x) grape.bgrape_calc_fid_grad_uni(opt_params,x);
        %fprintf('no grid \n');
    elseif ( (opt_params.rf_det_error>0.01) & (opt_params.mw_amp_error<0.01) )
        problem.objective = @(x) grape.bgrape_calc_fid_grad_gridrf_uni(opt_params,x);
        %fprintf('rf grid \n');
    elseif ( (opt_params.rf_det_error>0.01) & (opt_params.mw_amp_error>0.01) )
        problem.objective = @(x) grape.bgrape_calc_fid_grad_gridrfmw_uni(opt_params,x);
        %fprintf('rf and uw grid \n');
    else
        fprintf('bad inhomo errors.\n');
    end
else
    fprintf('bad iso_or_uni.\n');
end

search_attempts = 0;
fid_final = 0;

while ( (fid_final>-opt_params.fid_stop) && (search_attempts<opt_params.max_seeds) )

    search_attempts = search_attempts + 1;

    problem.x0 = 2*pi*rand(opt_params.timesteps,3);
    %fprintf('here inside 1 \n')
    [control_fields_final, fid_final, exitflag, output, grad_final] = fminunc(problem);
    %fprintf('here inside 2 \n')

end


opt_params.control_fields_final = control_fields_final;
opt_params.fid_search = fid_final;
opt_params.search_attempts = search_attempts;

opt_params.control_fields = control_fields_final;
opt_params.uni_final = grape.bgrape_calc_uni_final(opt_params);


if ( opt_params.iso_or_uni == 'iso')
    opt_params.iso_final = opt_params.uni_final*opt_params.init_iso;
    opt_params.fid_iso = grape.bgrape_mat_fid_iso(opt_params.target_iso,opt_params.iso_final,subspace_dim);
else
    proj_target_uni = opt_params.subspace_proj * opt_params.target_uni * opt_params.subspace_proj;
    proj_total_uni = opt_params.subspace_proj * opt_params.uni_final * opt_params.subspace_proj;
    opt_params.fid_center = grape.bgrape_mat_fid(proj_total_uni, proj_target_uni, subspace_dim);
end
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

