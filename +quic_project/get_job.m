function [job_struct] = get_job(project,job,options)
    arguments
        project (1,1) double {mustBeInteger}
        job (1,1) double {mustBeInteger}
        options.root (1,1) string = "";
        options.suffix = "";
    end

    root = quic_project.check_active_root(options.root,false);
    suffix = quic_project.check_active_workspace(options.suffix,false);
    

    [root_temp,target_file,~] = quic_project.get_info(project,root=root,suffix=suffix);
     
    target_struct = load(target_file);
    template = strrep(target_struct.template,"%s","*");
    fname = sprintf(template,job);
    
    files = dir(fullfile(root_temp,fname));
    N_files = numel(files);
    
    if N_files == 0
        job_struct = missing;
    end

    for ii = N_files:-1:1

        job_struct(ii) = load(fullfile(files(ii).folder,files(ii).name));
        
    end

end