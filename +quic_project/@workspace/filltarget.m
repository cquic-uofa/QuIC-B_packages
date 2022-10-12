function filltarget(obj,target_id,grape_type,options)

    arguments
        obj
        target_id (1,1) string
        grape_type (1,1) string {mustBeMember(grape_type,{'ngrape','bgrape'})}
        options.root (1,1) string = '';
    end

    root = quic_project.check_active_root(options.root,false);
            
    dir_name = fullfile(root,sprintf('workspace_%s',obj.name));
    target_folder = fullfile(dir_name,'targets');
    if ~isfolder(target_folder)
        mkdir(target_folder);
    end

    waveform_folder = fullfile(dir_name,'waveforms');
    if ~isfolder(waveform_folder)
        mkdir(waveform_folder);
    end

    count = 1;
    list_file = fullfile(dir_name,'target_list.txt');
    % end_line = false; 
    if isfile(list_file)
        txt=fileread(list_file);
        count = sum(txt==10)+1;
        % end_line = ~strcmp(txt(end),newline);
    end

    target_file = fopen(list_file,'a+');
    % if end_line
    %     fprintf(target_file,'\n');
    % end

    ind = strcmp(target_id,obj.model_id);

    model_handle = obj.model{ind};
    n_var = numel(obj.targetvar{ind});

    priority = cell2mat(obj.targetvar_priority{ind});
    [~, perm] = sort(priority,'descend'); 
    % rank low value priority before high value
    % if two vars have the same priority

    lengths = num2cell(cellfun(@numel,obj.targetval{ind}));
    
    % must permute lengths for iter to go in right order

    iter = ndfor(lengths{perm});
    N = numel(iter);
    read_offset = N;
    if strcmp(grape_type,'ngrape')
        extra_args = {'read_offset'};
    else
        extra_args = {};
    end
    
    target_list_template = '%-3d %-9s %-50s %-50s\n';

    while iter
        model_args = cell(1,2*n_var);
        inds = nextmat(iter);
        par_string_cell = cell(1,n_var);
        par_struct.target_id = target_id;
        par_struct.read_offset = read_offset;
        for ii = 1:n_var
            % ii = permute_ii permute_ii is just a list
            ii_perm = perm(ii);
            par_name = obj.targetvar{ind}{ii_perm};
            par_val = obj.targetval{ind}{ii_perm}(inds(ii));
            par_struct.(par_name) = {par_val,ii_perm};
            model_args{2*ii_perm-1} = par_name;
            model_args{2*ii_perm} = par_val;
            fmt = obj.targetvar_format{ind}{ii_perm};
            if strcmp(fmt,'')
                par_string_cell{ii_perm} = sprintf('%s%d',par_name,inds(ii)-1); % zero indexing for consistency
            else
                par_string_cell{ii_perm} = sprintf(strcat('%s',fmt),par_name,par_val);
            end
            eval(  sprintf('%s = %s;',par_name,num2str(par_val))  ); % this is for saving parameters in project_file
        end
        par_string = strjoin(par_string_cell,'_');
        project_file = sprintf('%s_%s_%s.mat',obj.name,target_id,par_string);

        project_folder = strjoin( [{char(target_id),'map'} par_string_cell{:}] , '/');
        
        target = model_handle(model_args{:});
        template = sprintf('%s_%s_%%s_%s_jn_%%d.mat',obj.name,target_id,par_string);

        save(fullfile(target_folder,project_file),'target','template',obj.targetvar{ind}{:},extra_args{:});

        obj.project_list{count} = par_struct;
        fprintf(target_file,target_list_template,count,grape_type,project_file,project_folder);
        count = count+1;
        % create a row in the target_list and automatically generate folder names and such
        % then save target with template and so forth

    end


    % now do it all again for read map
    if strcmp(grape_type,'ngrape')
        reset(iter)
        while iter
            model_args = cell(1,2*n_var);
            inds = nextmat(iter);
            par_string_cell = cell(1,n_var);
            par_struct.target_id = target_id;
            par_struct.read_offset = read_offset;
            for ii = 1:n_var
                ii_perm = perm(ii);
                par_name = obj.targetvar{ind}{ii_perm};
                par_val = obj.targetval{ind}{ii_perm}(inds(ii));
                par_struct.(par_name) = {par_val,ii_perm};
                model_args{2*ii_perm-1} = par_name;
                model_args{2*ii_perm} = par_val;
                fmt = obj.targetvar_format{ind}{ii_perm};
                if strcmp(fmt,'')
                    par_string_cell{ii_perm} = sprintf('%s%d',par_name,inds(ii)-1); % zero indexing for consistency
                else
                    par_string_cell{ii_perm} = sprintf(strcat('%s',fmt),par_name,par_val);
                end
                eval(  sprintf('%s = %s;',par_name,num2str(par_val))  ); % this is for saving parameters in project_file
            end
            par_string = strjoin(par_string_cell,'_');
            project_file = sprintf('?%s_%s_%s_read.mat',obj.name,target_id,par_string); % question mark denotes that project has not yet been found
            project_folder = strjoin( [{char(target_id),'read'} par_string_cell{:}] , '/');
            
            obj.project_list{count} = par_struct;
            fprintf(target_file,target_list_template,count,'bgrape',project_file,project_folder);
            count = count+1;
            % create a row in the target_list and automatically generate folder names and such
            % then save target with template and so forth

        end



    end

    fclose(target_file);
    
    

end