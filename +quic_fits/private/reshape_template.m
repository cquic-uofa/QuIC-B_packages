function reshaped_template = reshape_template(amp_factor, width_factor, center, signal_length, template_signal, template_center )
    % squish template and center is about new location

    % TODO fix signal length bit
    N = numel(template_signal);

    xq = (((1:signal_length) - center)*N/signal_length +2 )  / width_factor + template_center;

    % x = ((1:numel(template_signal))  - template_center) * width_factor + center;

    reshaped_template = amp_factor*interp1(1:N,template_signal,xq,'spline',0);

end