function opt_params = make_opt_params(waveform)

[timesteps,~] = size(waveform); 

u = load('+grape/bgrape_units.mat'); %note that frequencies have a factor of 2pi in them

samp_time = 4*u.us; %control phases are piecewise constant over this time
tot_time = samp_time*timesteps; %total control field time

mw_amp = 27.5*u.kHz; %rabi freq for for stretched state transition
rf_freq = 1000*u.kHz; %rf freq
rf_amp_x = 25*u.kHz; %rf larmor frequency x
rf_amp_y = 25*u.kHz; %rf larmor frequency y

rf_det_error = 40*u.Hz; %inhomo grid param for rf detuning, aaron val = 100 Hz,
mw_amp_error = 0*u.Hz; %inhomo grid param for mw amp, aaron val = 140 Hz,

fid_stop = 0.999; %stop search when this fid is reached
max_seeds = 10; %restart search this many times if fid is below fid_stop

iso_or_uni = 'uni';

subspace_vec = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];

% target_uni = uni_list_init;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%probably shouldn't edit this section!

%load vars into opt_params
opt_params.samp_time = samp_time;
opt_params.tot_time = tot_time;
opt_params.timesteps = timesteps;
opt_params.mw_amp = mw_amp;
opt_params.rf_freq = rf_freq;
opt_params.rf_amp_x = rf_amp_x;
opt_params.rf_amp_y = rf_amp_y;
opt_params.rf_det_error = rf_det_error;
opt_params.mw_amp_error = mw_amp_error;
opt_params.fid_stop = fid_stop;
opt_params.max_seeds = max_seeds;
opt_params.iso_or_uni = iso_or_uni;
opt_params.subspace_vec = subspace_vec;
opt_params.target_uni = missing;

%load operators into opt_params
opt_params = grape.bgrape_set_opt_params(opt_params);

control_fields_final = waveform;

opt_params.control_fields_final = control_fields_final;
opt_params.fid_search = missing;
opt_params.search_attempts = missing;

opt_params.control_fields = control_fields_final;
opt_params.uni_final = grape.bgrape_calc_uni_final(opt_params);


opt_params.fid_center = missing;

opt_params.rf_wave(1:2,:) = opt_params.control_fields_final(:,1:2)';
opt_params.mw_wave(1,:) = opt_params.control_fields_final(:,3)';
opt_params.points = opt_params.timesteps;
opt_params.rf_amp = opt_params.rf_amp_x;

end
