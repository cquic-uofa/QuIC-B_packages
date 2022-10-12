
function addtargetfn(obj,target_id,handle)
% this will add reference to a target function of the form
% function U = target(name,value)
%     arguments (Repeating)
%         name (1,1) string
%         value
%     end
%
%     U = ...
%
% end
    arguments
        obj
        target_id (1,1) string
        handle (1,1) function_handle
    end
    if any(strcmp(target_id,obj.model_id))
        error("target_id already exists")
    end

    obj.model{end+1} = handle;
    obj.model_id{end+1} = char(target_id);
    obj.targetvar{end+1} = {};
    obj.targetval{end+1} = {};
    obj.targetvar_priority{end+1} = {};
    obj.targetvar_format{end+1} = {};

    save(obj);
end