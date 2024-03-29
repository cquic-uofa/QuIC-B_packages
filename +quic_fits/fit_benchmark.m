function res = fit_benchmark(root,options)
    %
    % quic_fits.fit_benchmark(root,options)
    % Convenience function to quickly fit benchmark data
    %    
    % Arguments:
    %     root (1,1) string  : root directory
    %     options.format (1,1) string = "concat_unibench_20130715_R_%d_%d_tof_out_fit.mat"
    %                        : root director
    %     options.format_args (1,2) cell = {1:10,1:6}
    %                        : index ranges for file template
    %     options.iso_index (1,1) int32 = 10
    %                        : index of population representing fidelity
    % Output:
    %     res.prep_error     : fitted SPAM error
    %     res.step_error     : fitted error per step
    %     res.avg_fidelities : measured fidelities averaged at each step
    % 
    arguments (Repeating)
        root
    end
    arguments
        options.format (1,1) string = "concat_unibench_20130715_R_%d_%d_tof_out_fit.mat";
        options.format_args (1,2) cell = {1:10,1:6};
        options.iso_index (1,1) int32 = 10;
    end

    if isempty(root{1})
        root{1} = getenv("QuICDATA");
    end

    root = fullfile(root{:});

    N_steps = numel(options.format_args{2});
    N_avg = numel(options.format_args{1});
    fidelities = zeros(1,N_steps);
    for ii = options.format_args{1}
        for jj  = options.format_args{2}
            fname = fullfile(root,sprintf(options.format,ii,jj));
            solution = load(fname);
            fidelities(jj) = fidelities(jj) + solution.populations(options.iso_index);
        end
    end
    fidelities = fidelities/N_avg;

    % fit function from Brian Anderson's thesis
    fit_fn = @(x,xdata) 1/16 + (15/16) * (1-16*x(1)/15) * (1 - 16*x(2)/15).^xdata;
    lb = [0,0];
    ub = [1,1];
    x = lsqcurvefit(fit_fn,[0,0],0:(N_steps-1),fidelities,lb,ub);
    res.prep_error = x(1);
    res.step_error = x(2);
    res.avg_fidelities = fidelities;
    save(fullfile(root,"benchmark_fit.mat"),"-struct","res")

end