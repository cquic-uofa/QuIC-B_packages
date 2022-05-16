function mustBeValidProcessType(ProcessType)
    if ~(strcmp(ProcessType,"Exact")||strcmp(ProcessType,"Exper"))
        eidType = 'mustBeValidProcessType:notValidProcessType';
        msgType = 'ProcessType must be Exact or Exper.';
        throwAsCaller(MException(eidType,msgType))
    end
end