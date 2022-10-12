function expectwaveforms(obj,projects,state,steps,options)
    arguments
        obj
        projects (1,:) double {mustBeInteger}
        state (:,1) double
        steps (1,:) double {mustBeInteger}
        options.root (1,1) string = "";
        options.state_name = "init_state";
        options.basis (1,1) string = "Standard";
    end

root = quic_project.check_active_root(options.root,false);
suffix = obj.name;

if strcmpi(options.basis,"standard")||strcmpi(options.basis,"jz")
    concat_name = 'Jz_expect';
    offset_name = 'read_offset';
else
    concat_name = [char(options.basis) '_expect'];
    offset_name = ['read_offset_' char(options.basis)];
end

wave_root_list = cell(1,20); % probably won't go over 5
template_list = cell(1,20);
project_link = cell(1,20);
num_inds_list = cell(1,20);
temp_count = 1;
for project = projects

    prep_data.opt_params = quic_project.get_statemap(project,"best_fit","prep",options.state_name,root=root,suffix=suffix);
    if isnumeric(prep_data.opt_params)
        error('Statemap %s not found',options.state_name)
    end

    map_data = quic_project.get_fit(project,root=root,suffix=suffix);
    [~,target_file,~] = quic_project.get_info(project,root=root,suffix=suffix);
    target_struct = load(target_file);
    names = fieldnames(target_struct);
    if ~any(strcmp(names,offset_name))
        error('Basis %s has no associated waveforms',options.basis)
    end
    delta = target_struct.(offset_name);
    read_data = quic_project.get_fit(project+delta,root=root,suffix=suffix);
    
    par_struct = obj.project_list{project};
    wave_root = fullfile(root,['workspace_' char(suffix)],'concat',[char(suffix) '_' char(par_struct.target_id) '_' concat_name]);
    if ~exist(wave_root, 'dir')
        mkdir(wave_root)
    end

    
    % for each new label in the set add new template

    % create 2 templates

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



    for ii = steps
        opt_params = waveform_concat.sequence(prep_data.opt_params,1,map_data.opt_params,ii,read_data.opt_params,1);
        opt_params.concat_time = datetime('now');
        save(fullfile(wave_root,sprintf('kicked_pSpin_p_4_αi_%d_Λ_%.1f_Jz_expect_%d.mat',ai,Lambda,ii)),"opt_params")
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
