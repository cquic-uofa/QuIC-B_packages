function mustBeUnitary(U)
    [d,~] = size(U);
    cmp = abs(U*U'-eye(d)) < 1e4*ones(d)*eps;
    if ~all(cmp,'all') % compare within tolerance
        eidType = 'mustBeUnitary:notUnitary';
        msgType = 'Input must be unitary.';
        throwAsCaller(MException(eidType,msgType))
    end
end