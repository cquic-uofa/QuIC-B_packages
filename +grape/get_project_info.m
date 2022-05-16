function [dir_name,target_file,opt_type] = get_project_info(project,options)
    arguments
        project
        options.root = "./";
        options.suffix = "";
    end

    if strcmp(options.suffix,"")
        workspace = "workspace";
    else
        workspace = strcat("workspace_",options.suffix);
    end

    fname = fullfile(options.root,workspace,"target_list.txt");
    f = fopen(fname);
    data = textscan(f,"%s %s %s %d");
    fclose(f);

    dir_name    = data{1}{project};
    target_file = data{2}{project};
    opt_type    = data{3}{project};

    dir_name = fullfile(workspace,"waveforms",dir_name);
    target_file = fullfile(options.root,workspace,"targets",target_file);
    

end