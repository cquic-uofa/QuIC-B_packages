function solution = fit_SG(SG_signal,background)

    template_data = load("+quic_fits/template_data.mat");

    template_data.template_signal = desample_fn(template_data.template_signal,template_data.desample_factor); % TODO
    template_data.template_center = template_data.template_center/template_data.desample_factor;

    shift = mean(background.SG_tof_3(end-1000:end)) - mean(SG_signal.SG_tof_3(end-1000:end));

    signal_4 = filter_template(desample_fn(SG_signal.SG_tof_4.' - background.SG_tof_4,template_data.desample_factor)).';
    signal_3 = filter_template(desample_fn(SG_signal.SG_tof_3.' - background.SG_tof_3 + shift,template_data.desample_factor)).';

    solution_4 = fit_single_manifold( signal_4, template_data,  4);
    solution_3 = fit_single_manifold( signal_3, template_data,  3);

    areas.four = solution_4.areas;
    areas.three = solution_3.areas;

    areas_corr.four = areas.four .* template_data.area_correction_factors_4;
    areas_corr.three = areas.three .* template_data.area_correction_factors_3;

    areas_total = sum( [areas_corr.four areas_corr.three]);
    areas_corr_norm = [areas_corr.four areas_corr.three]/areas_total;
    popmax = max( areas_corr_norm );

    solution.areas = areas_corr_norm;
    solution.populations = [flip(areas_corr_norm(1:9)) areas_corr_norm(10:end)];

    solution.area_max = popmax;
    solution.signal_4 = signal_4;
    solution.signal_3 = signal_3;
    solution.signal_4 = signal_4;
    solution.best_fit_4 = solution_4.best_fit;
    solution.best_fit_3 = solution_3.best_fit;

    solution.solution_4 = solution_4;
    solution.solution_3 = solution_3;

    solution.single_fits_4(:,:) = solution_4.single_fit(:,:);
    solution.single_fits_3(:,:) = solution_3.single_fit(:,:);

    solution.area_correction_factors_4 = template_data.area_correction_factors_4;
    solution.area_correction_factors_3 = template_data.area_correction_factors_3; % change area correction factors in template_data file

end