function signal_out = filter_template(signal)

    %%%%% here for historical reasons
    %     order = 2; %greater than 6 is risky for numerical reasons, see documentation
    %     filter_type = 'low';
    %     f_cutoff = 1e3; %Hz
        
    %     %%% DEFINE FILTER PARAMETERS
    %     samprate = 1000000/desample_factor;
    %     f_nyquist = samprate/2;
    %     f_cutoff_normalized = f_cutoff/f_nyquist;
        
    %     %%% LOW PASS FILTER THE SIGNAL
    %     [b,a]=butter(order,f_cutoff_normalized,filter_type);
    % 	  filtered_signal = filter(b,a,signal);

    signal_out = signal - mean([  mean(signal(1:300)) mean(signal(end-300:1:end))]);
    signal_out(signal_out<0) = 0;

end