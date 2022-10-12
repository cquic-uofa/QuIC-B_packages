function fidelitywaveforms(obj,projects,state,steps,options)
    arguments
        obj
        projects (1,:) double {mustBeInteger}
        state (:,1) double
        steps (1,:) double {mustBeInteger}
        options.root (1,1) string = "";
        options.state_name = "init_state";
    end

root = quic_project.check_active_root(options.root,false);
suffix = obj.name;


wave_root_list = cell(1,20); % probably won't go over 5
template_list = cell(1,20);
project_link = cell(1,20);
num_inds_list = cell(1,20);
temp_count = 1;
for project = projects
    inds = quic_project.get_best_inds(project,root=root,suffix=suffix);
    num_inds = numel(inds);

    par_struct = obj.project_list{project};
    wave_root = fullfile(root,['workspace_' char(suffix)],'concat',[char(suffix) '_' char(par_struct.target_id) '_' 'fidelity']);
    if ~exist(wave_root, 'dir')
        mkdir(wave_root)
    end
    % for each new label in the set add new template
    template = ['~' char([char(par_struct.target_id) '_proj%%(proj:d)_jn_ind%%(jn_ind:d)_simfid_%%(fidstep:d).mat'])];
    % if template is new, then add it to the list

    if ~any(strcmp(wave_root_list,wave_root))
        wave_root_list{temp_count} = wave_root;
        template_list{temp_count} = template;
        project_link{temp_count} = {};
        num_inds_list{temp_count} = num_inds;
        temp_count = temp_count+1;
    end

    wave_root_loc = strcmp(wave_root_list,wave_root);
    project_link{wave_root_loc}{end+1} = project;
    

    for jj = 1:num_inds
        ind = inds(jj);
        state_label = sprintf('jn%d',ind);

        % check for preexisting statemap
        prep_data.opt_params = quic_project.get_statemap(project,state_label,'prep',options.state_name,root=root,suffix=suffix);
        if ~isstruct(prep_data.opt_params)
            prep_data = 1;
        end
        
        map_data = quic_project.get_job(project,ind,root=root,suffix=suffix);
        [optp_list,read_iso_list,prep_iso] = waveform_concat.step_fidelity(state,map_data,steps,sm_iso=prep_data);
        
        
        opt_params = prep_iso;
        quic_project.register_statemap(project,opt_params,state_label,'prep',options.state_name,root=root,suffix=suffix);

        N = numel(optp_list);

        for ii= 1:N
            opt_params = optp_list(ii);
            opt_params.concat_time = datetime('now');
            save(fullfile(wave_root,sprintf([char(par_struct.target_id) '_proj%d_jn_ind%d_simfid_%d.mat'],project,jj,steps(ii))),"opt_params")
            opt_params = read_iso_list(ii);
            quic_project.register_statemap(project,opt_params,state_label,'read',sprintf('step%d',steps(ii)),root=root,suffix=suffix);
        end

    end
end


for ii = 1:numel(wave_root_list)
    wave_root  = wave_root_list{ii};
    p_arr = cell2mat(project_link{ii});
    template = template_list{ii};

    vars = [...
        sprintf('#proj = [%s];',num2str(p_arr)) newline ...
        sprintf('#jn_ind = 1:%d;',num_inds_list{ii}) newline ...
        sprintf('#fidstep = [%s];',num2str(steps))...
    ];

    fid = fopen(fullfile(wave_root,'template.txt'),'w+');
    fprintf(fid,[template newline vars]);
    fclose(fid);

end


end
