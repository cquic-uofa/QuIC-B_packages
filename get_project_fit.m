function [target_struct] = get_project_fit(project)

    f = fopen("workspace/target_list.txt");
    data = textscan(f,"%s %s %s %d");
    fclose(f);

    target_file = data{2}{project};

    [~,name,ext] = fileparts(target_file);

    % dir_name = fullfile("workspace/waveforms/",dir_name);
    target_file = fullfile("workspace/targets",strcat(name,"_best_fit",ext));
    target_struct = load(target_file);

end