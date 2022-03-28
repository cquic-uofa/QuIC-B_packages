function mustBeValidDirection(direction)
    if ~(strcmp(direction,"x")||strcmp(direction,"y")||strcmp(direction,"z"))
        eidType = 'mustBeValidDirection:notValidDirection';
        msgType = 'Direction must be x, y, or z.';
        throwAsCaller(MException(eidType,msgType))
    end
end