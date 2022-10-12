function vertices = wire_polygon_vertices(R,r0,options)
% Generates a set of vertices defining a closed loop in the shape of a polygon
%
% Arguments
%    R         (1,1) double : Radial distance between each vertex and the center 
%                             of the polygon 
%    r0        (3,1) double : column vector pointing to center of polygon
% Keyword Arguments
%    nsides              (1,1) double  : number of sides of polygon
%    direction = [0;0;1] (3,1) double  : unit vector that is normal to the face of the polygon
%                                        in a right handed sense
%    theta = 0           (1,1) double  : angle defining angular offset, if theta is non-zero
%                                        each vertex will be rotated about the unit normal by
%                                        the angle theta
%    ccw = true          (1,1) logical : true if right handed, false if left handed
%

    arguments
        R double % radius
        r0 (3,1) double % center
        options.nsides (1,1) double {mustBeInteger} % number of sides
        options.direction (3,1) double = [0;0;1]; % direction of unit normal
        options.theta (1,1) double = 0; % angular offset
        options.ccw (1,1) logical = true; % direction of current about options.direction 
    end

    v1 = R*[sin(options.theta);cos(options.theta);0];
    if ~options.ccw
        v1(1) = -v1(1);
    end
    if ~all(options.direction==[0;0;1])
        n0 = [0;0;1];
        t = acos( options.direction'*n0 ); % rotation angle

        u = cross(n0,options.direction);
        u =  u/norm(u); % rotation unit vector

        R = magnetostatics.rotation(u,t);
        v1 = R*v1;
    end

    if options.ccw
        t = (2*pi/options.nsides);
    else
        t = -(2*pi/options.nsides);
    end
    R = magnetostatics.rotation(options.direction,t);

    vertices = zeros(options.nsides+1,3);

    r0 = r0';
    for ii=1:(options.nsides+1)
        vertices(ii,:) = v1'+r0;
        v1 = R*v1;
    end

end