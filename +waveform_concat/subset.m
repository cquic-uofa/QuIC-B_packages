function opt_params = subset(optp,range)

    
    timesteps = length(range);
    tot_time = timesteps*optp.samp_time;
    control_fields = optp.control_fields(range,:);

    opt_params = optp; % template that will be modified
    opt_params.timesteps = timesteps;
    opt_params.tot_time = tot_time;
    opt_params.control_fields = control_fields;
    opt_params.rf_wave = control_fields(:,1:2).';
    opt_params.mw_wave = control_fields(:,3).';
    opt_params.control_fields_final = control_fields;
    opt_params.points = timesteps;
    opt_params.uni_final = grape.bgrape_calc_uni_final(opt_params);

end