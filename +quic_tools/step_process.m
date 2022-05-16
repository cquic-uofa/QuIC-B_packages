function process = step_process(optp,n,options)
    arguments
        optp (1,1) struct
        n (:,1) double {mustBeInteger}
        options.exact_map (16,16) double {mustBeUnitary} = eye(16);
        options.runs (1,1) double {mustBeInteger} = 60;
        options.process_type (1,1) string {mustBeValidProcessType} = "Exper";
    end
    % gets the process matrix for given unitary after the given number of steps
    % Op2Vec(rho_fin) = process * Op2Vec(rho)
    % assumes quic_B hilbert space


    L = length(n);

    process = zeros(quic_const.DIM^2,quic_const.DIM^2,L);

    if strcmp(options.process_type,"Exact")
        uni_final = optp.target_uni;
        for ii = 1:L
            process(:,:,ii) = super_operators.AxAd(uni_final^n(ii));
        end
        return
    end
    
    Hz = 1;
    for ii = 1:options.runs
        % 2018v3 with inflated rf-dets
        rf_dets = 0*Hz + 100*randn(1)*Hz;
        rf_amps_x = 1 + 0.004*randn(1);
        rf_amps_y = 1 + 0.004*randn(1);
        mw_amps = 1 + 0.008*randn(1);
        phases = 0 + 0.1*randn(1)*(pi/180);
        
        %%% prep
        opt_params = optp;
        
        opt_params.rf_det = rf_dets;
        opt_params.rf_amp_x = opt_params.rf_amp_x * rf_amps_x;
        opt_params.rf_amp_y = opt_params.rf_amp_y * rf_amps_y;
        opt_params.mw_amp = opt_params.mw_amp * mw_amps;
        opt_params.control_fields(:,2) = opt_params.control_fields(:,2) + phases;
        
        opt_params = grape.bgrape_set_opt_params(opt_params);
        uni_final = options.exact_map'*grape.bgrape_calc_uni_final(opt_params)*options.exact_map;
        
        for jj = 1:L
            process(:,:,jj) = process(:,:,jj) + super_operators.AxAd(uni_final^n(jj));
        end
        
    
    end
    process = process/options.runs;
    
end