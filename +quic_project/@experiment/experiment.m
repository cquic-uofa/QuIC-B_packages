classdef experiment
properties (Access=private)
    name
    basis_names = {};
    bases = {};
    operator_names = {};
    operators = {};
    workspace
end

methods (Access=public)
    function obj = experiment(name,workspace)
        % if workspace is empty or if it is a string, then load from file else
        % pass workspace directly
        obj.name = name;
        obj.workspace = workspace;
    end
    % create fidelity waveforms % autogenerate file names and placement
    % create expectation value waveforms

    addbasis(obj,name,op)
    addoperator(obj,name,op)
    addprojects(obj,range)
    
    fidelitywaveforms(obj,state,steps,best) % these should autogenerate autodaq file pattern
    expectwaveforms(obj,state,basis_name,steps)
    sequencewaveforms(obj,project_id_array)
    MUBwaveforms(obj,state_steps,project) % allow sequence here as well


    linkdata(obj,folder)
    retrievedata(obj) % must have linked data and found template
    save(obj) % store in workspace folder/experiments

end

methods (Static)
    function obj = load_from_name(name,options)
        arguments
            name
            options.root = '';
            options.suffix = '';
        end

        root = quic_project.check_active_root(options.root);
        suffix = quic_project.check_active_workspace(options.suffix);

        if strcmp(suffix,'')
            wspace = 'workspace';
        else
            wspace = strcat('workspace_',suffix);
        end
        fname = fullfile(root,wspace,'experiments',sprintf('%s.mat',name));
        if ~isfile(fname)
            error('Invalid experiment')
        end

        data = load(fname);

        if isfield(data,'experiment_summary')
            obj = data.experiment_summary;
        else
            error('Invalid experiment')
        end

    end
end

end



%%% template  for usage

% jz = ... 
% experiment = quic_project.new_experiment('fidelity_filter',workspace) % options are evo or standard
% addprojects(experiment,1:11)
% addfidelitywaveforms(experiment,spin_up,0:15:45,1:3)

% addvariable(experiment,'alpha',linspace(.75,1.25,11)*pi)
% addvariable(experiment,'Lambda',[.7,2.5])
% addbasis(experiment,'jz',jz) % this will define an new basis and specify which read maps
% % create a set of read maps  for each basis element
% % if non, then default to standard basis or no read map if not evo
% populatetargets(experiment) % this will know if it is evo or not and populate accordingly
% % if standard, then just set everything to bgrape and add read maps for any basis element
% % if evo then create folders with map and read but set all read folders to ? until evaluation

% % assume filter_fn or perhaps call filter_fn if no filter detected
% % consider better ordering of arguments or leave best as a default
% fidelitywaveforms(experiment,name,state,steps,best) % create fidelity waveforms for all combinations
% % automatically register state names

% ... % assume all waveforms have been found and specified using save_fit
% % or perhaps generate 

% expectwaveforms(experiment,state,basis_name,steps)

% sequencewaveforms(experiment,variable_id_array) % for non evo waveforms

% linkdata(experiment,path_to_data)
% retrievedata(experiment,exp_typ) % exp_typ is fidelity, expect, or sequence, return cell array of structures
% % check if exp_typ has been previously called to generate waveforms


% subset(experiment)
% save(experiment,name) % automatically generate name and store in workspace/experiments/name.mat
% % create quic_project.load_experiment(name) as converse