function active_root = check_active_root(root,warn)

    arguments
        root (1,1) string = "";
        warn (1,1) = true;
    end
    if strcmp(root,"")
        active_root = getenv("PROJECT_ROOT");
        if isempty(active_root)
            active_root = "";
            if warn
                warning("PROJECT_ROOT environment variable not set, using current directory")
            end
        end
    else
        active_root = root;
    end


end