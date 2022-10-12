function [opt_params] = get_statemap(project,names,options)
    arguments
        project (1,1) double {mustBeInteger}
    end
    arguments (Repeating)
        names (1,1) string
    end
    arguments
        options.root (1,1) string = "";
        options.suffix (1,1) string = "";
    end
    % get project root, if registry exists, then load and append, else create
    % 

    root = quic_project.check_active_root(options.root,false);
    suffix = quic_project.check_active_workspace(options.suffix,false);
    

    [dir_full,~,~] = quic_project.get_info(project,root=root,suffix=suffix);

    registry_name = fullfile(dir_full,'statemap_registry.mat');
    
    if isfile(registry_name)
        registry = load(registry_name);
    else
        error('registry of statemaps has not yet been created')
    end

    try
        opt_params = getfield(registry,names{:});
    catch ME
        if strcmp(ME.identifier,'MATLAB:nonExistentField')
            opt_params = -1; % default when statemap not found
        else
            rethrow(ME)
        end
    end
    
end