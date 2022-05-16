function save_project_fit(project,options)
    arguments
        project
        options.ind = 1;
        options.root = "";
        options.date = "";
    end
    % store an array in subfolder with ordered list of best to worst,
    % then get project fit includes argument to select ordered best elements

    % TODO include root option

    [dir_name,target_file,opt_type] = grape.get_project_info(project,root=options.root);
    dir_full = fullfile(options.root,dir_name);
    % load everything in dir_name
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
    [path,name,ext] = fileparts(target_file);
    new_file = fullfile(path,strcat(name,'_best_fit',ext));
    copyfile(best_file,new_file);

    if strcmp(opt_type,'ngrape')
        read_file = fullfile(path,strcat(name,'_read',ext));
        dat1 = load(best_file);
        dat2 = load(target_file);
        target = dat1.exact_map';
        [~,temp_name,ext] = fileparts(dat2.template);
        template = fullfile(strcat(temp_name,"_read",ext));
        source_file = new_file;
        save(read_file,'target','template','source_file')
    end

end