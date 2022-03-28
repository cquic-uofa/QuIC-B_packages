function solution = fit_single_manifold( signal, template_data, manifold)

    % TODO add signal length change remove template desampling

    %fprintf('start fit_single_template')
    signal = reshape(signal,1,[]);
    
    if manifold == 4
        centers_guess = template_data.centers_guess_4;
        widths_guess = template_data.widths_guess_4;
    elseif manifold == 3
        % TODO reshape centers_guess
        centers_guess = template_data.centers_guess_3; % TODO fix the length issue
        widths_guess = template_data.widths_guess_3;
    else
        error("Manifold not recognized")
    end
    
    % getting initial guess using psuedoinverse
    dim = numel(centers_guess);
    signal_length = numel(signal);
    M = zeros(signal_length,dim);
    for ii = 1:dim
        M(:,ii) = reshape_template(1.0, widths_guess(ii), centers_guess(ii), signal_length, template_data.template_signal, template_data.template_center );
    end
    amps_guess = pinv(M)*signal';
    amps_guess(amps_guess<=0) = .001;
    % use psuedoinverse here
    % amps_guess = signal(centers_guess);


    template_signal = template_data.template_signal;
    template_center = template_data.template_center;

    params_guess = vertcat(reshape(amps_guess,1,[]),reshape(widths_guess,1,[]),reshape(centers_guess,1,[]));
    
    %This is the function that makes gaussians and subtracts them from data
    fit_error = @(fit_params) stern_gerlach_template_cost(fit_params,signal,template_signal,template_center,dim);
    
    %This code constrains each element of fit_params to be in some interval
    lb = zeros(3,length(params_guess)); %lower bound vector for optimization vector fit_params 
    ub = zeros(3,length(params_guess)); %upper bound vector for optimization vector fit_params
    %bounds on the amplitudes of the templates
    lb(1,:) = params_guess(1,:)*(0.1);
    ub(1,:) = params_guess(1,:)*10;
    %bounds on the widths of the templates
    lb(2,:) = params_guess(2,:) - 0.2;
    ub(2,:) = params_guess(2,:) + 0.2;
    %bounds on the centers of the templates
    % bd = 20; % is this supposed to be desample_factor
    bd = template_data.desample_factor;
    if manifold == 4
        lb(3,1:3) = params_guess(3,1:3) - 2500/bd; % 125
        ub(3,1:3) = params_guess(3,1:3) + 2500/bd;
        lb(3,4:6) = params_guess(3,4:6) - 3500/bd; % 175
        ub(3,4:6) = params_guess(3,4:6) + 3500/bd;
        lb(3,7:9) = params_guess(3,7:9) - 4500/bd; % 225
        ub(3,7:9) = params_guess(3,7:9) + 4500/bd;
    elseif manifold == 3
        lb(3,1:2) = params_guess(3,1:2) - 2500/bd; % 125
        ub(3,1:2) = params_guess(3,1:2) + 2500/bd;
        lb(3,3:5) = params_guess(3,3:5) - 3500/bd; % 175
        ub(3,3:5) = params_guess(3,3:5) + 3500/bd;
        lb(3,6:7) = params_guess(3,6:7) - 4500/bd; % 225
        ub(3,6:7) = params_guess(3,6:7) + 4500/bd;
    else
        error("this should be impossible to reach")
    end
                
    params_guess = reshape(params_guess,1,[]);
    lb = reshape(lb,1,[]);
    ub = reshape(ub,1,[]);
    % options = optimset('TolFun',1e-5,'TolX',1e-5,'MaxIter',150,'MaxFunEvals',1500,'Display','iter');
    options = optimset('TolFun',1e-6,'TolX',1e-6,'MaxFunEvals',1000000,'Display','iter');
    [best_params, ~, ~, ~] = ...
        fmincon(fit_error,params_guess,[],[],[],[],lb,ub,[],options);
    best_params = reshape(best_params,3,[]);

    solution.best_amps = best_params(1,:);
    solution.best_widths = best_params(2,:);
    solution.best_centers = best_params(3,:);
    
    len = numel(signal);
    fit = zeros(1,len);
    for ii = 1:dim
        fit = fit + reshape_template(best_params(1,ii),best_params(2,ii),best_params(3,ii),signal_length,template_signal,template_center);
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
        single_peak = reshape_template(best_params(1,k),best_params(2,k),best_params(3,k),signal_length,template_signal,template_center);
        solution.single_fit(k,:) = single_peak(1,:);
        solution.areas(k) = sum(single_peak);
    end
    

end