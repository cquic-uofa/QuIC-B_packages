function mustBeValidDomain(domain)
    if ~(strcmp(domain,"Complex")||strcmp(domain,"Real"))
        eidType = 'mustBeValidDomain:notValidDomain';
        msgType = 'Domain must be Complex or Real.';
        throwAsCaller(MException(eidType,msgType))
    end
end