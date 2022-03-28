function optp_list = append_MUB(opt_params)
        
    % concatenate all MUBS to given opt_params and return a list
    root = getenv("QuICMATROOT");
    MUB_root = fullfile(root,"QuIC-B_packages","MUB");
    
    optp_list(quic_const.DIM+1) = opt_params; % preallocating struct array
    for ii = 1:(quic_const.DIM+1)
        % this accounts for varying dates in the various basis files
        basis_file = dir(fullfile(MUB_root,sprintf("*basis_%d.mat",ii)));
        basis = load(fullfile(basis_file.folder,basis_file.name));
        optp_list(ii) = waveform_concat.sequence( opt_params,1,basis.opt_params,1);
    end


end