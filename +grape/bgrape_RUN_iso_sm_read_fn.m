function [opt_params] = bgrape_RUN_iso_sm_read_fn(init_iso)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%bgrape by Brian Eric Anderson
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('+grape/bgrape_units.mat'); %note that frequencies have a factor of 2pi in them

% load(infile);

fprintf('starting bgrape_RUN_iso_sm_read ... \n')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

samp_time = [4]*us; %control phases are piecewise constant over this time
tot_time = [100]*us; %total control field time

mw_amp = [27.5]*kHz; %rabi freq for for stretched state transition
rf_freq = [1000]*kHz; %rf freq
rf_amp_x = [25]*kHz; %rf larmor frequency x
rf_amp_y = [25]*kHz; %rf larmor frequency y

rf_det_error = [40]*Hz; %inhomo grid param for rf detuning, aaron val = 100 Hz,
mw_amp_error = [0]*Hz; %inhomo grid param for mw amp, aaron val = 140 Hz,

fid_stop = 0.999; %stop search when this fid is reached
max_seeds = 20; %restart search this many times if fid is below fid_stop

iso_or_uni = 'iso';
subspace_dim = 1;

target_iso = [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0]';
% target_iso = iso_fin;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%probably shouldn't edit this section!

%load vars into opt_params
opt_params.samp_time = samp_time;
opt_params.tot_time = tot_time;
opt_params.mw_amp = mw_amp;
opt_params.rf_freq = rf_freq;
opt_params.rf_amp_x = rf_amp_x;
opt_params.rf_amp_y = rf_amp_y;
opt_params.rf_det_error = rf_det_error;
opt_params.mw_amp_error = mw_amp_error;
opt_params.fid_stop = fid_stop;
opt_params.max_seeds = max_seeds;
opt_params.date = grape.get_date_str();
opt_params.iso_or_uni = iso_or_uni;
opt_params.subspace_dim = subspace_dim;
opt_params.init_iso = init_iso;
opt_params.target_iso = target_iso;

%load operators into opt_params
opt_params = grape.bgrape_set_opt_params(opt_params);

%call solver
tic
opt_params = grape.bgrape_solver( opt_params );
opt_params.runtime = toc;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%for load to tabor-8026 software in 568
opt_params.rf_wave(1:2,:) = opt_params.control_fields_final(:,1:2)';
opt_params.mw_wave(1,:) = opt_params.control_fields_final(:,3)';
opt_params.points = opt_params.timesteps;
opt_params.rf_amp = opt_params.rf_amp_x;

%save the file for Magnetic Sublevel States
% save(outfile,'opt_params');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('done with bgrape_RUN_iso_sm_read \n')

end
