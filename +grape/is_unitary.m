function [ ans ] = is_unitary( op )

    dim = length(op);
    
    temp = op * ctranspose(op);
    
    sub = temp - eye(dim);
    
    if ( abs(max(max(sub))) < 0.0000000001 )
        ans = 1;
    else
        ans = 0;
    end

end

