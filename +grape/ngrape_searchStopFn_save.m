function [ stop ] = ngrape_searchStopFn_save( ~, optimValues, ~, infid_stop )

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

%%%%%%
% global variable defined using assignin('base','history',struct('fval',[],'time',[]))

solHistory = evalin('base','solHistory');

ind = solHistory.ind;
solHistory.fval(ind) = optimValues.fval;
solHistory.time(ind) = now;
solHistory.ind = solHistory.ind+1;

assignin('base','solHistory',solHistory);

if (optimValues.fval < (infid_stop))
    stop = true;
end

end