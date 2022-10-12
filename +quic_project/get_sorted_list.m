function [sorted_list] = get_sorted_list(project,options)
    arguments
        project
        options.ind = 1;
        options.root = "";
        options.date = "";
        options.suffix = "";
    end
    % store an array in subfolder with ordered list of best to worst,
    % then get project fit includes argument to select ordered best elements

    root = quic_project.check_active_root(options.root,false);
    suffix = quic_project.check_active_workspace(options.suffix,false);
    

    [dir_full,~,~] = quic_project.get_info(project,root=root,suffix=suffix);
    % load everything in dir_name
    % select best and store adjacent to target
    fname = fullfile(dir_full,'sorted_list.mat');
    if ~isfile(fname)
        error('Must call grape.filter_project_fn first')
    end
    sorted_list = load(fname);

end