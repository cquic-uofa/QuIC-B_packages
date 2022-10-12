function [indices] = get_best_inds(project,options)
    arguments
        project
        options.root = "";
        options.suffix = "";
    end

    root = quic_project.check_active_root(options.root);
    suffix = quic_project.check_active_workspace(options.suffix);

    if strcmp(suffix,"")
        workspace = "workspace";
    else
        workspace = strcat("workspace_",suffix);
    end

    fname = fullfile(root,workspace,"project_index.txt");
    if ~isfile(fname)
        error("project_index.txt not found")
    end

    f = fopen(fname);
    ln = fgetl(f);
    while ischar(ln)
        index = str2double(strsplit(ln));
        if index(1) == project
            indices = index(2:end);
            fclose(f);
            return
        end
        ln = fgetl(f);
    end
    fclose(f);
    error("No indices associated with project")

end