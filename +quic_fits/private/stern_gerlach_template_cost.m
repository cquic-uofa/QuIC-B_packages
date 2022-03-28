function [chi2] = stern_gerlach_template_cost(params,signal,template_signal,template_center,dim)
    % centers = params(1:9);
    % amps = params(10:18);
    % widths = params(19:27);
    params = reshape(params,3,[]);

    signal_length = numel(signal);
    
    fit = zeros(1,signal_length);
    for ii = 1:dim
        fit = fit + reshape_template(params(1,ii),params(2,ii),params(3,ii),signal_length,template_signal,template_center);
    end

    chi2 = sum((fit - signal).^2);

end