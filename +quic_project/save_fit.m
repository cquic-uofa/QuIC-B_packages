function save_fit(project,options)
    arguments
        project (1,:)
        options.ind = -1;
        options.best = -1;
        options.jn = -1;
        options.root = "";
        options.date = "";
        options.suffix = "";
    end
    % store an array in subfolder with ordered list of best to worst,
    % then get project fit includes argument to select ordered best elements

    if numel(project)~=1
        for ii = project
            try
                quic_project.save_fit(ii,ind=options.ind,best=options.best,date=options.date,root=options.root,suffix=options.suffix)
            catch ME
                warning("error on project %d",ii)
                continue
            end
        end
    end

    root = quic_project.check_active_root(options.root,false);
    suffix = quic_project.check_active_workspace(options.suffix,false);

    [dir_full,target_file,opt_type] = quic_project.get_info(project,root=root,suffix=suffix);
    


    if options.best > 0
        if options.ind > 0
            error('do not specify both best and ind keywords')
        end
        if options.jn > 0
            error('do not specify both best and jn keywords')
        end
        [data,file] = quic_project.get_best(project,ind=options.best);

        target_struct = load(target_file);

        template = strrep(target_struct.template,"%s","(\d+)");
        template = strrep(template,"%d","(\d+)");
        match = regexp(file,template,'tokens');
        try
            best_jn = match{1}(2);
        catch ME
            error('target file corrupt')
        end
        
        % must define best_file and best_jn
        [path,name,ext] = fileparts(target_file);
        new_file = fullfile(path,strcat(name,'_best_fit',ext));

        data.job = best_jn; % store the best job index in fitted file
        save(new_file,'-struct','data');



    elseif options.ind>0
        if options.jn > 0
            error('do not specify both ind and jnkeywords')
        end

        inds = quic_project.get_best_inds(project,root=root,suffix=suffix);
        best_jn = inds(options.ind);

        % load everything in dir_name
        % select best and store adjacent to target

        % files = load(fname).files;
        
        % if ~strcmp(options.date,"")
        %     dates = regexp(files,"(\d\d\d\d\d\d\d\d)","tokens");
        %     dates = datetime(string(dates),"InputFormat","yyyyMMdd");
        %     cmp_date = datetime(options.date,"InputFormat","yyyyMMdd");
        %     files = files(dates==cmp_date);
        % end

        % % copy files(ind) to newname and new place
        % best_file = fullfile(dir_full,files(options.ind));

        
        target_struct = load(target_file);
        template = strrep(target_struct.template,"%s","*");
        fname = sprintf(template,best_jn);
        
        files = dir(fullfile(dir_full,fname));
        N_files = numel(files);
        

        if N_files ~= 1
            error('job index not unique')
        end

        best_file = fullfile(files.folder,files.name);
        % must define best_file and best_jn
        [path,name,ext] = fileparts(target_file);
        new_file = fullfile(path,strcat(name,'_best_fit',ext));

        data = load(best_file);
        data.job = best_jn; % store the best job index in fitted file
        save(new_file,'-struct','data');
    
    elseif options.jn>0

        best_jn = options.jn;
        
        target_struct = load(target_file);
        template = strrep(target_struct.template,"%s","*");
        fname = sprintf(template,best_jn);
        
        files = dir(fullfile(dir_full,fname));
        N_files = numel(files);
        

        if N_files ~= 1
            error('job index not unique')
        end

        best_file = fullfile(files.folder,files.name);
        % must define best_file and best_jn
        [path,name,ext] = fileparts(target_file);
        new_file = fullfile(path,strcat(name,'_best_fit',ext));

        data = load(best_file);
        data.job = best_jn; % store the best job index in fitted file
        save(new_file,'-struct','data');
    else
        error('specify at least best, jn, or ind keyword')
    end


    registry_name = fullfile(dir_full,'statemap_registry.mat');
    if isfile(registry_name)
        registry = load(registry_name);
        data = registry.(sprintf("jn%d",best_jn));
        registry.best_fit = data;
    
        save(registry_name,'-struct','registry')
    % else
        % warning("no statemap registry")
    end


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