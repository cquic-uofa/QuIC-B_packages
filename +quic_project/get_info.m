function [dir_name,target_file,opt_type] = get_info(project,options)
    arguments
        project
        options.root = "";
        options.suffix = "";
    end

    root = quic_project.check_active_root(options.root);
    suffix = quic_project.check_active_workspace(options.suffix);

    if strcmp(suffix,"")
        workspace = "workspace";
    else
        workspace = strcat("workspace_",suffix);
    end

    fname = fullfile(root,workspace,"target_list.txt");
    f = fopen(fname);
    data = textscan(f,"%d %s %s %s");
    fclose(f);

    dir_name    = data{4}{project};
    target_file = data{3}{project};
    opt_type    = data{2}{project};

    dir_name = fullfile(root,workspace,"waveforms",dir_name);
    target_file = fullfile(root,workspace,"targets",target_file);
    

end