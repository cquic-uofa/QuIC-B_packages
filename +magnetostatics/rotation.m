function R = rotation(rotation_axis)
% Generates a geometric rotation matrix about axis defined by unit vector u and 
% angle theta
%
% Arguments
%    rotation_axis (3,1) double : vector defining axis of rotation
%                                 magnitude defines angle of rotation

    arguments
        rotation_axis (3,1) double
    end

    theta = norm(rotation_axis);
    u = rotation_axis/theta;

    % rotation about vector u by angle θ
    % R = [u, v, v*]@[[1, 0, 0],[0, exp(1j*θ), 0],[0, 0, exp(-1j*θ)]]@[[u'],[v'],[v.T]]
    % find orthogonal conjugates (u⋅v=0 and u⋅v'=0)
        
    v = zeros(3,1);
    if u(1)==1
        v = [0; 1; -1j]/sqrt(2);
    elseif u(2)==0
        v(1) = 1j*u(3);
        v(2) = 1;
        v(3) = -1j*u(1);
        v = v/norm(v);
    else
        y = -(u(3)*u(1)-1j*u(2))/(u(2)^2 + u(3)^2); % fails here when u(1) is 1
        v(1) = 1;
        v(2) = -u(3)*y/u(2)  - u(1)/u(2); % fail here when u(2) is 0
        v(3) = y;
        v = v/norm(v);
    end
     R = u*u' + 2*real(  (v*v')*exp(1j*theta)  );

end