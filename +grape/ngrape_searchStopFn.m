function [ stop ] = ngrape_searchStopFn( x, optimValues, state, infid_stop )

%%%%%
% ngrape_rotSearchStopFn.m
%
% Checks if the infidelity from the optimzation is less than infid_stop.
%
% 2018.09.11 v1.0 nkl - First version. Adapted from bgrape_SearchStopFn.m
%%%%%

stop = false;
% Check if objective function is less than 5.
%time = toc;

if (optimValues.fval < (infid_stop))
    stop = true;
end

end