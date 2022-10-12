function addtargetvar(obj,target_id,var_name,range,options)
    arguments
        obj
        target_id
        var_name
        range
        options.priority (1,1) double {mustBeInteger} = -1;
        options.format = '';
    end

    % first determine if there is already 
    ind = strcmp(target_id,obj.model_id);
    obj.targetvar{ind}{end+1} = var_name;
    obj.targetvar_priority{ind}{end+1} = options.priority;
    obj.targetvar_format{ind}{end+1} = options.format;
    obj.targetval{ind}{end+1} = range;


end