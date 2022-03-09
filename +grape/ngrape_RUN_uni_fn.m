function [opt_params] = ngrape_RUN_uni_fn( job_arg, target_uni )

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ngrape_RUN_uni_fn.m
%
% Driver adapted from bgrape_RUN_uni to search for unitaries while also
% allowing for the basis of the final unitary to be optimized by the
% routine. This new functional compares the unitary generated to a Utarg_w,
% the target unitary modulo some rotation represented by a matrix W. In
% this way, we can explicitly calculate a gradient instead of relying on
% fminsearch and numerical estimation, thereby speeding up the search and
% (hopefully) improving final waveform fidelities. Formerly
% ngrape_RUN_rot_uni_fn.
%
% NOTE: This code is only to be used for unitaries; isometries are no
% longer a function being updated. Use bgrape for conventional isometry
% searches.
%
% Details for the gradient calculation can be found in lab notes.
% job_arg = [ job_num, tot_time, rf_det_error, num_tries ]
%
% 2020.05.03 v1.2 nkl - Renamed and revamped. This is now the main-line
%                       version of ngrape.
% 2018.11.11 v1.1 nkl - Added RF AMP inhomo search, hard coded, no input
%                       vars for this version.
% 2018.09.27 v1.0 nkl - Final formatting, changed how date was added, rolled
%                       version forward to 1.0.
% 2018.09.11 v0.3 nkl - Formatting and cleanup for supercomputer runs. We
%                       believe this implementation to be working properly.
% 2018.09.09 v0.2 nkl - Updated code to save final waveforms correctly and
%                       keep track of final rotation matrix.
% 2018.09.06 v0.1 nkl - First version.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('+grape/bgrape_units.mat'); %note that frequencies have a factor of 2pi in them
fprintf('started ngrape_RUN_uni_fn \n')
startDate = grape.getDateStr();

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

samp_time = [4]*us; %control phases are piecewise constant over this time
tot_time = [job_arg(2)]*us; %total control field time

mw_amp = [27.5]*kHz; %rabi freq for for stretched state transition
rf_freq = [1000]*kHz; %rf freq
rf_amp_x = [25]*kHz; %rf larmor frequency x
rf_amp_y = [25]*kHz; %rf larmor frequency y

rf_det_error = [job_arg(3)]*Hz; %inhomo grid param for rf detuning, aaron val = 100 Hz,
mw_amp_error = [0]*Hz; %inhomo grid param for mw amp, aaron val = 140 Hz,
rf_amp_error = [0]*Hz; %inhomo grid param for rf amp with BOTH X an Y, nathan start 100 Hz

infid_stop = 1e-5; %stop search when this infidelity is reached
max_seeds = 10; %restart search this many times if fid is below fid_stop
num_seeds = job_arg(4); %save this number of seeds before finishing the job regardless of final fidelity

% fid_stop = 1; %stop search when this fid is reached
% max_seeds = 1; %restart search this many times if fid is below fid_stop

TolFun = 1e-10;
TolX = 1e-10;
% opt_params.TolFun = TolFun;
% opt_params.TolX = TolX;

iso_or_uni = 'uni'; % NOTE: This version _only_ works for unitaries as of v1.2

subspace_vec = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load(file_load);
% target_uni = uni_list_init;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%probably shouldn't edit this section!

for kk = 1:num_seeds

    %load vars into opt_params
    opt_params.samp_time = samp_time;
    opt_params.tot_time = tot_time;
    opt_params.mw_amp = mw_amp;
    opt_params.rf_freq = rf_freq;
    opt_params.rf_amp_x = rf_amp_x;
    opt_params.rf_amp_y = rf_amp_y;
    opt_params.rf_det_error = rf_det_error;
    opt_params.mw_amp_error = mw_amp_error;
    opt_params.rf_amp_error = rf_amp_error;
    opt_params.infid_stop = infid_stop;
    opt_params.max_seeds = max_seeds;
    opt_params.iso_or_uni = iso_or_uni;
    opt_params.subspace_vec = subspace_vec;
    opt_params.target_uni = target_uni;
    opt_params.job_num = job_arg(1);

    %load operators into opt_params
    opt_params = grape.bgrape_set_opt_params(opt_params);

    %call solver
    tic
    opt_params = grape.ngrape_solver( opt_params );
    opt_params.runtime = toc;
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %for load to tabor-8026 software in 568
    opt_params.rf_wave(1:2,:) = opt_params.control_fields_final(:,1:2)';
    opt_params.mw_wave(1,:) = opt_params.control_fields_final(:,3)';
    opt_params.points = opt_params.timesteps;
    opt_params.rf_amp = opt_params.rf_amp_x;

    %save the file
    
    % save(sprintf(file_save,job_arg(1)), 'opt_params');


end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('finished ngrape_RUN_uni_fn \n')
end
