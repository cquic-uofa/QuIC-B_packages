function [optp_list,read_iso_list,prep_iso] = step_fidelity(init_state,map_data,steps,options)
    arguments
        init_state (:,1) double
        map_data (1,1) struct
        steps (1,:) int32
        options.type (1,1) string = "Simulator";
        options.sm_iso (1,1) = 1;
    end

    % iso_prep =  exact_map*state
    % read is exact_map'
    % experiment fidelity and simulation fidelity

    if strcmp(options.type,"Simulator")
        uni_map = map_data.exact_map*map_data.opt_params.target_uni*map_data.exact_map';
    elseif strcmp(options.type,"Experiment")
        uni_map = grape.bgrape_calc_uni_final(map_data.opt_params);
    else
        error('Simulation type "%s" not recognized',options.type)
    end
    % % should this be grape.calc_uni_final(map_params) instead

    psi_init = map_data.exact_map*init_state;

    N = numel(steps);

    steps = cast(steps,'double');
    fin_states = zeros(quic_const.DIM,N);
    for ii = 1:N
        fin_states(:,ii) = uni_map^(steps(ii)-1)*psi_init;
    end

    % prep_iso
    if ~isstruct(options.sm_iso)
        prep_iso = grape.bgrape_RUN_iso_sm_prep_fn(psi_init);
    else
        prep_iso = options.sm_iso;
    end

    for ii = N:-1:1 % reverse to preallocate on first iteration
        read_iso_list(ii) = grape.bgrape_RUN_iso_sm_read_fn(fin_states(:,ii));
        % 2022/03/23 changed fidelity convention
        optp_list(ii) = waveform_concat.sequence(prep_iso,1,map_data.opt_params,steps(ii),read_iso_list(ii),1);
    end
    
end