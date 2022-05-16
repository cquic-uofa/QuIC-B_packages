function [job_struct] = get_project_job(project,job,options)
    arguments
        project (1,1) double {mustBeInteger}
        job (1,1) double {mustBeInteger}
        options.root (1,1) string = "";
        options.target_list (1,1) string = "target_list.txt";
        options.target_folder (1,1) string = "targets";
        options.waveforms_folder (1,1) string = "waveforms";
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

    folder = data{1}{project};
    root = fullfile(options.root,workspace,options.waveforms_folder,folder);
    
    target_file = data{2}{project};

    % dir_name = fullfile("workspace/waveforms/",dir_name);
    target_file = fullfile(options.root,workspace,options.target_folder,target_file);
    target_struct = load(target_file);
    template = strrep(target_struct.template,"%s","*");
    fname = sprintf(template,job);
    
    files = dir(fullfile(root,fname));
    N_files = numel(files);
    for ii = N_files:-1:1
        job_struct(ii) = load(fullfile(files(ii).folder,files(ii).name));
    end

end