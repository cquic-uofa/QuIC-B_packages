function opt_params = sequence(optp,steps)
    arguments (Repeating)
        optp (1,1) struct
        steps (1,1) double
    end

    % expect seq to be of the form seq(ii).opt_params,seq(ii).n
    N = numel(optp);
    tot_time = 0;
    timesteps = 0;
    for ii = 1:N
        tot_time = tot_time + optp{ii}.tot_time * steps{ii};
        timesteps = timesteps + optp{ii}.timesteps * steps{ii};
    end

    control_fields = zeros(timesteps,3);
    offset = 1;

    
    for ii = 1:N
        n_ii = optp{ii}.timesteps;
        for jj = 1:steps{ii}
            control_fields(offset:(offset+n_ii-1),:) = optp{ii}.control_fields;
            offset = offset + n_ii;
        end
    end

    opt_params = optp{1}; % template that will be modified
    opt_params.timesteps = timesteps;
    opt_params.tot_time = tot_time;
    opt_params.control_fields = control_fields;
    opt_params.rf_wave = control_fields(:,1:2).';
    opt_params.mw_wave = control_fields(:,3).';
    opt_params.control_fields_final = control_fields;
    opt_params.points = timesteps;
    opt_params.uni_final = grape.bgrape_calc_uni_final(opt_params);

end