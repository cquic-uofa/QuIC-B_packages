function mustBeHalfInteger(J)
    if ~(floor(2*J)==2*J)
        eidType = 'mustBeHalfInteger:notHalfInteger';
        msgType = 'Input must be integer or half integer.';
        throwAsCaller(MException(eidType,msgType))
    end
end