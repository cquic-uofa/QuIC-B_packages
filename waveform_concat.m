classdef waveform_concat

methods (Access=public)

    function opt_params = sequence(sequence)

        % expect sequence to be of the form sequence(ii).opt_params,sequence(ii).n
        N = numel(sequence);
        tot_time = 0;
        timesteps = 0;
        for ii = 1:N
            tot_time = tot_time + sequence(ii).opt_params.tot_time * sequence(ii).n;
            timesteps = timesteps + sequence(ii).opt_params.timesteps * sequence(ii).n;
        end
    
        control_fields = zeros(timesteps,3);
        offset = 1;
   
        
        for ii = 1:N
            n_ii = sequence(ii).opt_params.timesteps;
            for jj = 1:sequence(ii).n
                control_fields(offset:(offset+n_ii-1),:) = sequence(ii).opt_params.control_fields;
                offset = offset + n_ii;
            end
        end
    
        opt_params = sequence(1).opt_params; % template that will be modified
        opt_params.timesteps = timesteps;
        opt_params.tot_time = tot_time;
        opt_params.control_fields = control_fields;
        opt_params.rf_wave = control_fields(:,1:2).';
        opt_params.mw_wave = control_fields(:,3).';
        opt_params.control_fields_final = control_fields;
        opt_params.points = timesteps;
        opt_params.uni_final = grape.bgrape_calc_uni_final(opt_params);
    
    end

    function optp_list = append_MUB(opt_params)
        
        % concatenate all MUBS to given opt_params and return a list
        root = getenv("QuICMATROOT");
        MUB_root = fullfile(root,"QuIC-B_packages","MUB");
        
        steps(1).opt_params = opt_params;
        steps(1).n = 1;

        optp_list(quic_const.DIM+1) = opt_params; % preallocating struct array
        for ii = 1:(quic_const.DIM+1)
            % this accounts for varying dates in the various basis files
            basis_file = dir(fullfile(MUB_root,sprintf("*basis_%d.mat",ii)));
            basis = load(fullfile(basis_file.folder,basis_file.name));
            steps(2).opt_params = basis.opt_params;
            steps(2).n = 1;
            optp_list(ii) = waveform_concat.sequence(steps);
        end


    end
    
    function [optp_list,read_iso_list,prep_iso] = step_fidelity(prep_params,map_params,steps,exact_map)

        % iso_prep =  exact_map*state
        % read is exact_map'
        uni_map = exact_map*map_params.target_uni*exact_map';
        psi_init = exact_map*quic_const.INIT_ISO;

        N = numel(steps);


        fin_states = zeros(quic_const.DIM,N);
        for ii = 1:N
            fin_states(:,ii) = uni_map^(steps(ii))*psi_init;
        end
        % prepare reads at steps 1 10 20 30 40 50 60 70 80 90 100

        % prep_iso
        prep_iso = grape.bgrape_RUN_iso_sm_prep_fn(psi_init);
        % save('waveforms/pSpin_4_res4/spin_up_iso_prep.mat','opt_params')
        
        % preparing sequence for concatenation
        sequence(1).opt_params = prep_params;
        sequence(1).n = 1;
        sequence(2).opt_params = map_params;
        sequence(2).n = 0;
        sequence(3).n = 1; % for read, fill in opt_params later

        optp_list(N) = map_params; % preallocating struct array
        read_iso_list(N) = prep_params;
        for ii = 1:N
            read_iso_list(ii) = grape.bgrape_RUN_iso_sm_read_fn(fin_states(:,ii));
            sequence(2).n = steps(ii);
            sequence(3).opt_params = read_iso_list(ii);
            optp_list(ii) = waveform_concat.sequence(sequence);
        end
        
    end

end

end