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
    opt_params.uni_final = grape.bgrape_calc_uni_final(opt_params);

end
