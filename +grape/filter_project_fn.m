function filter_project_fn(project,options)
    arguments
        project
        options.root = "./";
    end
    % store an array in subfolder with ordered list of best to worst,
    % then get project fit includes argument to select ordered best elements

    % TODO include root option

    [dir_name,target_file,opt_type] = grape.get_project_info(project,root=options.root);
    dir_full = fullfile(options.root,dir_name);
    % load everything in dir_name
    % select best and store adjacent to target
    dir_struct = dir(dir_full);
    files = dir_struct(~[dir_struct.isdir]);
    N_files = length(files);

    % filter waveforms by max fidelity
    fids =  zeros(N_files,1);
    
    for ii = 1:N_files
        dat = load(fullfile(files(ii).folder,files(ii).name));
        if ~isfield(dat,'fidelity')
            fids(ii) = -1;
        else
            fids(ii) = dat.fidelity;
        end
    end
    [~,inds] = sort(fids,'descend');

    bad_keys = (fids(inds)<0);
    root = files(1).folder;
    files = {files(inds).name};
    files(bad_keys) = []; % remove files that are not  proper waveforms

    % files = fullfile({files(inds).folder}, {files(inds).name} );
    save(fullfile(root,'sorted_list'),'dir_name','files')

end