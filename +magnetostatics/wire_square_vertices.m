function vertices = wire_square_vertices(L,r0,options)
% Generates a set of vertices defining a closed loop in the shape of a square
%
% Arguments
%     L        (1,1) double : side length of the square 
%    r0        (3,1) double : column vector pointing to center of square
% Keyword Arguments
%    direction = [0;0;1] (3,1) double  : unit vector that is normal to the face of the square
%                                        in a right handed sense
%    theta = 0           (1,1) double  : angle defining angular offset, if theta is non-zero
%                                        each vertex will be rotated about the unit normal by
%                                        the angle theta
%    ccw = true          (1,1) logical : true if right handed, false if left handed
%

    arguments
        L (1,1) double % side length
        r0 (3,1) double
        options.direction (3,1) double = [0;0;1]; % direction of normal vector
        options.theta (1,1) double = 0; % angular offset
        options.ccw (1,1) logical = true; % true if right handed current flow
    end

    vertices = magnetostatics.wire_polygon_vertices(L/sqrt(2),r0,nsides=4,direction=options.direction,theta=options.theta+pi/4,ccw=options.ccw);

end