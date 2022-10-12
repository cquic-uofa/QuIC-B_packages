function filter_fn(project,options)
    arguments
        project (1,:)
        options.root = "";
        options.suffix = "";
    end

    if numel(project)~=1
        for ii = project
            try
                quic_project.filter_fn(ii,root=options.root,suffix=options.suffix)
            catch ME
                warning("error on project %d",ii)
                continue
            end
        end
    end


    % store an array in subfolder with ordered list of best to worst,
    % then get project fit includes argument to select ordered best elements

    root = quic_project.check_active_root(options.root,false);
    suffix = quic_project.check_active_workspace(options.suffix,false);
    
    [dir_full,~,~] = quic_project.get_info(project,root=root,suffix=suffix);
    % load everything in dir_name
    % select best and store adjacent to target
    dir_struct = dir(dir_full);
    files = dir_struct(~[dir_struct.isdir]);
    N_files = length(files);
    if N_files == 0
        warning("filtering empty project")
        return
    end

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
    root_temp = files(1).folder;
    files = {files(inds).name};
    files(bad_keys) = []; % remove files that are not  proper waveforms

    % files = fullfile({files(inds).folder}, {files(inds).name} );
    save(fullfile(root_temp,'sorted_list'),'dir_full','files')

end