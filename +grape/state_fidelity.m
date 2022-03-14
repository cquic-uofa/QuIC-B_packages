function fidelity = state_fidelity(rho1,rho2)
    sq_rho1 = sqrtm(rho1);
    fidelity = abs(trace(sqrtm(sq_rho1*rho2*sq_rho1)))^2;
end