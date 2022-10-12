function register_statemap(project,opt_params,names,options)
    arguments
        project (1,1) double {mustBeInteger}
        opt_params (1,1) struct
    end
    arguments (Repeating)
        names (1,1) string
    end
    arguments
        options.root (1,1) string = "";
        options.suffix (1,1) string = "";
    end
    % get project root, if registry exists, then load and append, else create
    % 

    root = quic_project.check_active_root(options.root,false);
    suffix = quic_project.check_active_workspace(options.suffix,false);
    
    [dir_full,~,~] = quic_project.get_info(project,root=root,suffix=suffix);
    
    registry_name = fullfile(dir_full,'statemap_registry.mat');
    if isfile(registry_name)
        registry = load(registry_name);
    else
        registry = struct();
    end

    registry = setfield(registry,names{:},opt_params);

    save(registry_name,'-struct','registry')
    
end