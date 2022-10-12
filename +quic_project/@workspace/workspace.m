classdef workspace < handle
    properties (Access=public)
        name
        dscr
        model = {}; % function handle cell array
        model_id = {};

        targetvar = {};
        targetval = {};
        targetvar_priority = {};
        targetvar_format = {};

        save_file;

        project_list = {}; % each element will be struct with 
        % have to define function to compare struct

    end

    methods (Access=public)
        function obj = workspace(name,dscr,options)
            arguments
                name (1,1) string
                dscr (1,1) string
                options.root = ""
            end
            
            root = quic_project.check_active_root(options.root,false);
            
            obj.name = name;
            dir_name = fullfile(root,sprintf("workspace_%s",name));
            if isfolder(dir_name)
                fname = fullfile(dir_name,strcat(name,'.mat'));
                obj = quic_project.load_workspace(fname);
                % load project instead
                return
            else
                mkdir(dir_name)
            end
            fname_struct = what(dir_name);
            obj.save_file = fullfile(fname_struct.path,'summary_class.mat');


            obj.dscr = dscr; % add this to a README as well
            readme = fullfile(dir_name,"README.txt");
            fid = fopen(readme,'w');
            fprintf(fid,dscr);
            fclose(fid);


            save(obj)
        end

        addtargetfn(obj,target_id,target) % use target id to pass variable names and the like
        addtargetvar(obj,target_id,var_name,range)
        targetsummary(obj) % print all active targets
        filltarget(obj,target_id,grape_type) % populate target_list and targets folder
        
        fidelitywaveforms(obj,projects,label,state,steps,options)

        projectsummary(obj)
        p = fetchproject(obj,map_type,var_name,value) % return project number with var_name with value
        % this should never have to loop through anything more than like 50 or so 
        % make this have repeating arguments
        % can be slow
        % make use of containers.Map
        save(obj)
    end

    methods (Static)

        function obj = load_from_name(options)
            arguments
                options.root = "";
                options.suffix = "";
            end

            root = quic_project.check_active_root(options.root);
            suffix = quic_project.check_active_workspace(options.suffix);

            if strcmp(suffix,'')
                wspace = 'workspace';
            else
                wspace = strcat('workspace_',suffix);
            end
            fname = fullfile(root,wspace,'summary_class.mat');
            data = load(fname);

            if isfield(data,'summary')
                obj = data.summary;
            else
                error('Invalid workspace')
            end

        end

    end

end

