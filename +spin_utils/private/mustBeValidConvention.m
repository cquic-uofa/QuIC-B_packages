function mustBeValidConvention(convention)
    if ~(strcmp(convention,"Standard")||strcmp(convention,"Reversed"))
        eidType = 'mustBeValidConvention:notValidConvention';
        msgType = 'Convention must be Standard or Reversed.';
        throwAsCaller(MException(eidType,msgType))
    end
end