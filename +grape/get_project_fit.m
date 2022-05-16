function [target_struct] = get_project_fit(project,options)
    arguments
        project (1,1) double {mustBeInteger}
        options.root (1,1) string = "";
        options.target_list (1,1) string = "target_list.txt";
        options.target_folder (1,1) string = "targets";
        options.suffix = "";
    end

    
    if strcmp(options.suffix,"")
        workspace = "workspace";
    else
        workspace = strcat("workspace_",options.suffix);
    end



    f = fopen(fullfile(options.root,workspace,options.target_list));
    data = textscan(f,"%s %s %s %d");
    fclose(f);

    target_file = data{2}{project};

    [~,name,ext] = fileparts(target_file);

    % dir_name = fullfile("workspace/waveforms/",dir_name);
    target_file = fullfile(options.root,workspace,options.target_folder,strcat(name,"_best_fit",ext));
    target_struct = load(target_file);

end