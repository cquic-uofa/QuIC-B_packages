function active_workspace = check_active_workspace(workspace,warn)

    arguments
        workspace (1,1) string = "";
        warn (1,1) = true;
    end
    if strcmp(workspace,"")
        active_workspace = getenv("PROJECT_WORKSPACE");
        if isempty(active_workspace)
            active_workspace = "";
            if warn
                warning("PROJECT_WORKSPACE environment variable not set, using default workspace")
            end
        end
    else
        active_workspace = workspace;
    end


end