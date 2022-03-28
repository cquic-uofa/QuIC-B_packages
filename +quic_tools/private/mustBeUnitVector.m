function mustBeUnitVector(n)
    if ~(abs(norm(n)-1)<(1.5*eps)) % n/norm(n) is good to +/- eps
        eidType = 'mustBeUnitVector:notUnitVector';
        msgType = 'Input must be unit vector.';
        throwAsCaller(MException(eidType,msgType))
    end
end