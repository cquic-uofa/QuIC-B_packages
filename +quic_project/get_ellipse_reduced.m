function [an,V,D,floquet_pops,state_sensitivity] = get_ellipse_reduced(map_data,initial_state)
% get 15 different points
% for each 

data = load('+quic_project/ellipse_points.mat');

% must keep track of initial eigenvectors

[V,D] = eig(map_data.opt_params.uni_final,'vector');
% F = state in Floquet basis
% initial state in standard basis is exact_map'*V*F

% use floquet_pops to decide which fidelities are the most important
floquet_pops = abs(V'*map_data.exact_map*initial_state).^2;


infid = zeros(32,16);
% 33 different types of fidelity to possibly measure
for ii = 1:32


    rf_dets   = data.points(1,ii);
    rf_amps_x = data.points(2,ii);
    rf_amps_y = data.points(3,ii);
    mw_amps   = data.points(4,ii);
    phases    = data.points(5,ii);
    
    %%% prep
    opt_params = map_data.opt_params;
    
    opt_params.rf_det = rf_dets;
    opt_params.rf_amp_x = opt_params.rf_amp_x * rf_amps_x;
    opt_params.rf_amp_y = opt_params.rf_amp_y * rf_amps_y;
    opt_params.mw_amp = opt_params.mw_amp * mw_amps;
    opt_params.control_fields(:,2) = opt_params.control_fields(:,2) + phases;
    
    opt_params = grape.bgrape_set_opt_params(opt_params);
    uni_final = grape.bgrape_calc_uni_final(opt_params);

    [Vt,~] = eig(uni_final,'vector');

    % now compare Vt and Dt to V and D
    % for vectors, choose [fid,jmax] = max(V(:,jj)'*Vt)
    % for phases, choose abs(15 + D(jj)'*Dt(jmax))/16
    for jj = 1:16
        infid(ii,jj) = 1 - max(abs(V(:,jj)'*Vt));
    end
    
end

% weights gives importance of each fidelity
% error_weights gives importance of each error channel
% error_weights = [40,.004,.004,.008,.1*pi/180];


an = zeros(1,16);
for jj = 1:16
    % ellipse_fit is pinv of features matrix where features = [x1^2 x1*y1 y1^2...;x2^2 x2*y2 y2^2...;...]
    coeff = data.ellipse_fit*infid(:,jj);

    % turn coefficient vector into matrix
    a = triu(ones(5));
    a(a>0) = coeff;
    a = (a+a')/2;
    an(jj) = norm(a);

end

state_sensitivity = an*floquet_pops;

end