function [target_struct] = get_fit(project,options)
    arguments
        project (1,1) double {mustBeInteger}
        options.root (1,1) string = "";
        options.suffix = "";
    end

    root = quic_project.check_active_root(options.root,false);
    suffix = quic_project.check_active_workspace(options.suffix,false);
    

    [~,target_file,~] = quic_project.get_info(project,root=root,suffix=suffix);

    [path,name,ext] = fileparts(target_file);

    target_file = fullfile(path,strcat(name,"_best_fit",ext));
    target_struct = load(target_file);

end