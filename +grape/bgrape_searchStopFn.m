function stop = bgrape_searchStopFn(x, optimValues, state, fid_stop)
stop = false;
% Check if objective function is less than 5.
%time = toc;

if (optimValues.fval < (-fid_stop))
    stop = true;
end

end