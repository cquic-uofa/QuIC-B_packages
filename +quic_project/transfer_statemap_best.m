function transfer_statemap_best(project,best,options)
    arguments
        project
        best
        options.root = "";
        options.suffix = "";
    end


    root = quic_project.check_active_root(options.root,false);
    suffix = quic_project.check_active_workspace(options.suffix,false);

    [dir_full,~,~] = quic_project.get_info(project,root=root,suffix=suffix);
    
    registry_name = fullfile(dir_full,'statemap_registry.mat');
    if isfile(registry_name)
        registry = load(registry_name);
    else
        error("no statemap registry")
    end

    data = registry.(sprintf("best%d",best));
    registry.best_fit = data;

    save(registry_name,'-struct','registry')


end