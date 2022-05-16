function fidelity = state_fidelity(rho1,rho2,options)
    arguments
        rho1 (:,:) double
        rho2 (:,:) double
        options.state_type (1,1) string = "Density";
    end

    switch options.state_type
        case "Density"
            [d11,d12] = size(rho1);
            [d21,d22] = size(rho2);
            assert(d11==d12,"First density matrix must be square: has dimensions (%d,%d)",d11,d12)
            assert(d21==d22,"Second density matrix must be square: has dimensions (%d,%d)",d21,d22)
            assert(d11==d22,"Density matrices have different dimensions: have dimensions DIM(rho1)=%d, DIM(rho2)=%d",d11,d22)
            sq_rho1 = sqrtm(rho1);
            fidelity = abs(trace(sqrtm(sq_rho1*rho2*sq_rho1)))^2;
        case "Vector"
            [d11,d12] = size(rho1);
            [d21,d22] = size(rho2);
            assert(d12==1,"First state must be column vector")
            assert(d22==1,"Second state must be column vector")
            assert(d11==d21,"States have different dimensions: have dimensions DIM(psi1)=%d, DIM(psi2)=%d",d11,d21)
            fidelity  = abs(rho1'*rho2)^2;
        case "Super"
            [d11,d12] = size(rho1);
            [d21,d22] = size(rho2);
            assert(d12==1,"First operator vector must be column vector")
            assert(d22==1,"Second operator vector must be column vector")
            assert(d11==d21,"States have different dimensions: have dimensions DIM(psi1)=%d, DIM(psi2)=%d",d11,d21)
            d = sqrt(d11);
            assert((floor(d)-d)==0,"Operator vectors must be a dimension that is a perfect square" )
            
            rho1 = super_operators.Vec2Op(rho1);
            rho2 = super_operators.Vec2Op(rho2);
            sq_rho1 = sqrtm(rho1);
            fidelity = abs(trace(sqrtm(sq_rho1*rho2*sq_rho1)))^2;

        otherwise
            eidType = 'mustBeValidStateType:notValidStateType';
            msgType = 'Input must be "Density", "Vector", or "Super".';
            throwAsCaller(MException(eidType,msgType))

    end
end