function B_mesh = B_line(r,I,start_point,end_point)
% Evaluates wire with current I flowing from start point start_point to end_point
% at positions r where last dimension of r is 3
%
% Arguments
%    r         (...,3) double : positions at which to evaluate magnetic fields
%    I           (1,1) double : current flowing through wire
%    start_point (3,1) double : column vector pointing to current source
%    end_point   (3,1) double : column vector pointing to current sink
%
    arguments
        r                 double
        I           (1,1) double
        start_point (3,1) double
        end_point   (3,1) double
    end

    % μ0*I0/(4π)  * (-yⁱ + xʲ)/(x²+y²)  *  (  (z + L/2)/√(x²+y²+(z + L/2)²) - (z - L/2)/√(x²+y²+(z-L/2)²) | L/2 )
    C = 1e4*(1.25663706212e-6)*I/(4*pi);

    % transform coordinates in order to map start_point->(0,0,L/2) end_point->(0,0,-L/2)
    r0 = (start_point+end_point)/2; % initial translation to put center of wire at origin

    L = norm(start_point-end_point);
    zh = [0;0;1]; % final direction to map (start_point-end_point) to
    t = acos((start_point-end_point)'*zh/L); % rotation angle

    u = cross(zh,start_point-end_point);
    u = u/norm(u); % rotation unit vector

    R = magnetostatics.rotation(u*t); % R*(start_point-end_point) = L*zh

    n = ndims(r); % get axis for tensorproduct
    r0 = reshape(r0,[ones(1,n-1),3]);
    rp = tensorprod(r-repmat(r0,[size(r,1:(n-1)) 1]),R,n,1); % rotate all coordinates at once

    % calculate B field in transformed coordinates
    otherdims = repmat({':'},1,ndims(r)-1);

    % evaluate magnetic field in tranformed frame
    M = C*(  (rp(otherdims{:},3) + L/2)./sqrt(rp(otherdims{:},1).^2+rp(otherdims{:},2).^2+(rp(otherdims{:},3) + L/2).^2) - (rp(otherdims{:},3) - L/2)./sqrt(rp(otherdims{:},1).^2+rp(otherdims{:},2).^2+(rp(otherdims{:},3)-L/2).^2) ).*(1 ./ (rp(otherdims{:},1).^2 + rp(otherdims{:},2).^2));
    B_mesh = zeros(size(r));
    B_mesh(otherdims{:},1) = -rp(otherdims{:},2).*M;
    B_mesh(otherdims{:},2) =  rp(otherdims{:},1).*M;

    B_mesh = tensorprod(B_mesh,R',n,1); % rotate field back into regular frame
        
end