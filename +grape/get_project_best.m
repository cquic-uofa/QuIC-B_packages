function [fit_struct] = get_project_best(project,options)
    arguments
        project
        options.ind = 1;
        options.root = "./";
        options.date = "";
        options.suffix = "";
    end
    % store an array in subfolder with ordered list of best to worst,
    % then get project fit includes argument to select ordered best elements

    % TODO include root option

    [dir_name,~,~] = grape.get_project_info(project,root=options.root,suffix=options.suffix);
    % load everything in dir_name
    dir_full = fullfile(options.root,dir_name);
    % select best and store adjacent to target
    fname = fullfile(dir_full,'sorted_list.mat');
    if ~isfile(fname)
        error('Must call grape.filter_project_fn first')
    end
    files = load(fname).files;

    if ~strcmp(options.date,"")
        dates = regexp(files,"(\d\d\d\d\d\d\d\d)","tokens");
        dates = datetime(string(dates),"InputFormat","yyyyMMdd");
        cmp_date = datetime(options.date,"InputFormat","yyyyMMdd");
        files = files(dates==cmp_date);
    end
    
    % copy files(ind) to newname and new place
    best_file = fullfile(dir_full,files(options.ind));
    fit_struct = load(best_file);

end