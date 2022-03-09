function [ hammy_d ] = bgrape_calc_hammy_d( opt_params )

timesteps = opt_params.timesteps;

hammy_zero = opt_params.hammy_zero;
rf_bias = opt_params.rf_bias;
rf_freq = opt_params.rf_freq;
rf_amp_x = opt_params.rf_amp_x;
rf_amp_y = opt_params.rf_amp_y;
mw_amp = opt_params.mw_amp;
rf_det = opt_params.rf_det;
grel = opt_params.grel;
fx4 = opt_params.fx4;
fy4 = opt_params.fy4;
fz4 = opt_params.fz4;
fx3 = opt_params.fx3;
fy3 = opt_params.fy3;
fz3 = opt_params.fz3;
mw_sx = opt_params.mw_sx;
mw_sy = opt_params.mw_sy;

phix = opt_params.control_fields(:,1);
phiy = opt_params.control_fields(:,2);
phimw = opt_params.control_fields(:,3);

XX = opt_params.rwa_order_val;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hammy_d = zeros(14,timesteps);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for tt=1:timesteps
    hammy_d(1,tt) = ( ( (rf_amp_x/2)*(-sin(phix(tt)))*grel*(1-((XX*rf_bias*(1+grel))/(2*rf_freq))) ) + ...
                         ( XX*(rf_amp_x/2)*(-sin(phix(tt)))*(rf_det/(2*rf_freq))*grel ) ); %deriv of fx3 with respect to phix
    hammy_d(2,tt) = ( ( (rf_amp_x/2)*(-sin(phix(tt))) ) + ...
                         ( XX*(rf_amp_x/2)*(rf_det/(2*rf_freq))*cos(phix(tt)) ) );% d of fx4 wrt phix
    hammy_d(3,tt) = ( ( (rf_amp_x/2)*cos(phix(tt))*grel*(1+((XX*rf_bias*(1+grel))/(2*rf_freq))) ) + ...
                         ( XX*(rf_amp_x/2)*cos(phix(tt))*(rf_det/(2*rf_freq))*grel ) );% d of fy3 wrt phix
    hammy_d(4,tt) = ( ( (rf_amp_x/2)*(-cos(phix(tt))) ) + ...
                         ( XX*(rf_amp_x/2)*(rf_det/(2*rf_freq))*(sin(phix(tt))) ) );% d of fy4 wrt phix
    hammy_d(5,tt) = XX*( (-1*(grel^2)/(16*rf_freq)) * ...
                            ( ( (rf_amp_x^2)*((4*sin(2*phix(tt)))) ) + ...
                            ( (-2)*rf_amp_x*rf_amp_y*cos( phix(tt) - phiy(tt) ) ) ) );% d of fz3 wrt phix
    hammy_d(6,tt) = XX*( (1/(16*rf_freq)) * ...
                            ( ( (rf_amp_x^2)*((4*sin(2*phix(tt)))) ) + ...
                            ( 2*rf_amp_x*rf_amp_y*cos( phix(tt) - phiy(tt) ) ) ) );% d of fz4 wrt phix
    
    hammy_d(7,tt) = ( ( (rf_amp_y/2)*cos(phiy(tt))*(-grel)*(1+((XX*rf_bias*(1+grel))/(2*rf_freq))) ) + ...
                         ( XX*(rf_amp_y/2)*cos(phiy(tt))*(rf_det/(2*rf_freq))*(-grel) ) );% d of fx3 wrt phiy
    hammy_d(8,tt) = ( ( (rf_amp_y/2)*cos(phiy(tt)) ) + ...
                         ( XX*(rf_amp_y/2)*(rf_det/(2*rf_freq))*(-sin(phiy(tt))) ) );% d of fx4 wrt phiy
    hammy_d(9,tt) = ( ( (rf_amp_y/2)*(-sin(phiy(tt)))*(grel)*(1-((XX*rf_bias*(1+grel))/(2*rf_freq))) ) + ...
                         ( XX*(rf_amp_y/2)*sin(phiy(tt))*(rf_det/(2*rf_freq))*(grel) ) );% d of fy3 wrt phiy
    hammy_d(10,tt) = ( ( (rf_amp_y/2)*(-sin(phiy(tt))) ) + ...
                         ( XX*(rf_amp_y/2)*(rf_det/(2*rf_freq))*cos(phiy(tt)) ) );% d of fy4 wrt phiy
    hammy_d(11,tt) = XX*( (-1*(grel^2)/(16*rf_freq)) * ...
                            ( ( (rf_amp_y^2)*((4*sin(2*phiy(tt)))) ) + ...
                            ( (2)*rf_amp_x*rf_amp_y*cos( phix(tt) - phiy(tt) ) ) ) );% d of fz3 wrt phiy
    hammy_d(12,tt) = XX*( (1/(16*rf_freq)) * ...
                            ( ( (rf_amp_y^2)*((4*sin(2*phiy(tt)))) ) + ...
                            ( (-2)*rf_amp_x*rf_amp_y*cos( phix(tt) - phiy(tt) ) ) ) );% d of fz4 wrt phiy
    
    hammy_d(13,tt) =  ( (mw_amp/2)*(-sin(phimw(tt))) );%d of sx wrt phimw
    hammy_d(14,tt) =  ( (mw_amp/2)*(-cos(phimw(tt))) );%d of sy wrt phimw
end          
          
          
end

