classdef quic_fit
% standard tools for fitting Stern-Gerlach signals in QuIC B


% scs_from_unit_vector(n,J[,con])
% scs_from_polar_angles(theta,phi,J[,con])

% conventions are standard {J,J-1,...-J} or bgrape {-J,-J+1,...J}
% ensembles are {'uni','ortho','symp'}

methods (Static)
    
    function solution = fit_SG(SG_signal,background)

        template_data = load("template_data.mat");

        template_data.template_signal = quic_fit.desample_fn(template_data.template_signal,template_data.desample_factor); % TODO
        template_data.template_center = template_data.template_center/template_data.desample_factor;

        shift = mean(background.SG_tof_3(end-1000:end)) - mean(SG_signal.SG_tof_3(end-1000:end));

        signal_4 = quic_fit.filter_template(quic_fit.desample_fn(SG_signal.SG_tof_4.' - background.SG_tof_4,template_data.desample_factor)).';
        signal_3 = quic_fit.filter_template(quic_fit.desample_fn(SG_signal.SG_tof_3.' - background.SG_tof_3 + shift,template_data.desample_factor)).';

        solution_4 = quic_fit.fit_single_manifold( signal_4, template_data,  4);
        solution_3 = quic_fit.fit_single_manifold( signal_3, template_data,  3);

        areas.four = solution_4.areas;
        areas.three = solution_3.areas;

        areas_corr.four = areas.four .* template_data.area_correction_factors_4;
        areas_corr.three = areas.three .* template_data.area_correction_factors_3(2:8);

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
        solution.area_correction_factors_3 = template_data.area_correction_factors_3(2:8); % change area correction factors in template_data file

    end

    function recursive_fit(root)

        dir_struct = dir(root);
        
        files = dir_struct(~[dir_struct.isdir]);
        folders = dir_struct([dir_struct.isdir]);
        
        for ii = 1:numel(folders)
            % 
            if strcmp(folders(ii).name,".")||strcmp(folders(ii).name,"..")
                continue % these are always present
            end
            nroot = fullfile(folders(ii).folder,folders(ii).name);
            recursive_fit(nroot);
        
        end
        
        key = strcmp("background.mat",{files.name});
        background_file = files(key);
        data_files = files(~key);
        if ~isempty(background_file)
            % do the stuff
            background = load(fullfile(background_file(1).folder,background_file(1).name));
            ndir = strcat(background_file.folder,"_fits");
            mkdir(ndir);
            for ii = 1:numel(data_files)
                fin = fullfile(data_files(ii).folder,data_files(ii).name);
                % make parallel folder %(name)_fits with same file names suffixed with fit
                data = load(fin);
                if (~isfield(data,"SG_tof_3"))||(~isfield(data,"SG_tof_4"))
                    continue
                end
                [~,fname,fext] = fileparts(data_files(ii).name);
        
                fout = fullfile(ndir,strcat(fname,"_fit",fext));
        
                solution = quic_fit.fit_SG(data,background);
                save(fout,"-struct","solution")
            end
        end
        
    end

    % function fit_uni_run_calAllPeaks_automated()

    % end

end
methods (Access=private,Static)

    function signal_ds = desample_fn(signal,factor)
        % reduce number of points in vector for faster fitting

        signal_ds = signal(1:factor:end);

    end

    function reshaped_template = reshape_template(amp_factor, width_factor, center, template_signal, template_center )
        % squish template and center is about new location
    
        x = ((1:numel(template_signal))  - template_center) * width_factor + center;

        reshaped_template = amp_factor*interp1(x,template_signal,1:numel(template_signal),'spline',0);

    end

    function [chi2] = stern_gerlach_template_cost(params,signal,template_signal,template_center,dim)
        % centers = params(1:9);
        % amps = params(10:18);
        % widths = params(19:27);
        params = reshape(params,3,[]);

        len = numel(signal);
        
        fit = zeros(1,len);
        for ii = 1:dim
            fit = fit + quic_fit.reshape_template(params(1,ii),params(2,ii),params(3,ii),template_signal,template_center);
        end

        chi2 = sum((fit - signal).^2);

    end

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

    function solution = fit_single_manifold( signal, template_data, manifold)

            %fprintf('start fit_single_template')
            signal = reshape(signal,1,[]);
            
            if manifold == 4
                dim = 9;
                centers_guess = template_data.centers_guess_4;
                widths_guess = template_data.widths_guess;
            elseif manifold == 3
                dim = 7;
                % TODO reshape centers_guess
                centers_guess = template_data.centers_guess_3(2:8); % TODO fix the length issue
                widths_guess = template_data.widths_guess(2:8);
            else
                error("Manifold not recognized")
            end
            
            amps_guess = signal(centers_guess);

            % amps_guess = [signal(centers_guess(1)),signal(centers_guess(2)),signal(centers_guess(3)),...
            %     signal(centers_guess(4)),signal(centers_guess(5)),signal(centers_guess(6)),...
            %     signal(centers_guess(7)),signal(centers_guess(8)),signal(centers_guess(9))];
            
            template_signal = template_data.template_signal;
            template_center = template_data.template_center;

            params_guess = vertcat(reshape(amps_guess,1,[]),reshape(widths_guess,1,[]),reshape(centers_guess,1,[]));
            
            %This is the function that makes gaussians and subtracts them from data
            fit_error = @(fit_params) quic_fit.stern_gerlach_template_cost(fit_params,signal,template_signal,template_center,dim);
            
            %This code constrains each element of fit_params to be in some interval
            lb = zeros(3,length(params_guess)); %lower bound vector for optimization vector fit_params 
            ub = zeros(3,length(params_guess)); %upper bound vector for optimization vector fit_params
            %bounds on the centers of the templates
            % bd = 20; % is this supposed to be desample_factor
            bd = template_data.desample_factor;
            if manifold == 4
                lb(1,1:3) = params_guess(1,1:3) - 2500/bd; % 125
                ub(1,1:3) = params_guess(1,1:3) + 2500/bd;
                lb(1,4:6) = params_guess(1,4:6) - 3500/bd; % 175
                ub(1,4:6) = params_guess(1,4:6) + 3500/bd;
                lb(1,7:9) = params_guess(1,7:9) - 4500/bd; % 225
                ub(1,7:9) = params_guess(1,7:9) + 4500/bd;
            elseif manifold == 3
                lb(1,1:2) = params_guess(1,1:2) - 2500/bd; % 125
                ub(1,1:2) = params_guess(1,1:2) + 2500/bd;
                lb(1,3:5) = params_guess(1,3:5) - 3500/bd; % 175
                ub(1,3:5) = params_guess(1,3:5) + 3500/bd;
                lb(1,6:7) = params_guess(1,6:7) - 4500/bd; % 225
                ub(1,6:7) = params_guess(1,6:7) + 4500/bd;
            else
                error("this should be impossible to reach")
            end
            %bounds on the amplitudes of the templates
            lb(2,:) = params_guess(2,:)*(0.1);
            ub(2,:) = params_guess(2,:)*10;
            %bounds on the widths of the templates
            lb(3,:) = params_guess(3,:) - 0.2;
            ub(3,:) = params_guess(3,:) + 0.2;
            
            
            params_guess = reshape(params_guess,1,[]);
            lb = reshape(lb,1,[]);
            ub = reshape(ub,1,[]);
            options = optimset('TolFun',1e-4,'TolX',1e-4,'MaxIter',150,'MaxFunEvals',1500,'Display','iter');
            [best_params, ~, ~, ~] = ...
                fmincon(fit_error,params_guess,[],[],[],[],lb,ub,[],options);
            best_params = reshape(best_params,3,[]);

            solution.best_centers = best_params(1,:);
            solution.best_amps = best_params(2,:);
            solution.best_widths = best_params(3,:);
            
            len = numel(signal);
            fit = zeros(1,len);
            for ii = 1:dim
                fit = fit + quic_fit.reshape_template(best_params(1,ii),best_params(2,ii),best_params(3,ii),template_signal,template_center);
            end
            solution.best_fit = fit;            
            
            solution.error_vector = (solution.best_fit - signal).^2;
            solution.best_error = sum(solution.error_vector);
            solution.max_error = sum(signal.^2);
            
            % Use this for extracting the individual peaks from a fit. Don't forget the
            % statement in the k loop!
            solution.single_fit = zeros(9,5000);
            
            %extract populations from the gaussian areas
            for k = 1:dim
                single_peak = quic_fit.reshape_template(best_params(1,k),best_params(2,k),best_params(3,k),template_signal,template_center);
                solution.single_fit(k,:) = single_peak(1,:);
                solution.areas(k) = sum(single_peak);
            end
            

    end

end
end

