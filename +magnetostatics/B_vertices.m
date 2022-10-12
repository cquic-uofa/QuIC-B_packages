function B = B_vertices(r,I,r_vert)
% Evaluates wire with current I flowing through vertices
% at positions r where last dimension of r is 3
%
% Arguments
%    r         (...,3) double : positions at which to evaluate magnetic fields
%    I           (1,1) double : current flowing through wire
%    r_vert      (:,3) double : collection of row vectors where each row vector points to a 
%                               vertex in a sequence of vertices
%
% Current flows from r_vert(ii,:) to r_vert(ii+1,:)
% If r_vert(ii,:) is NaN, this indicates a break in the loop which allows one to program 
% multiple sets of closed loops within a single set of vertices

    arguments
        r                 double
        I           (1,1) double
        r_vert      (:,3) double
    end

    B = zeros(size(r));

    [N_points,~] = size(r_vert);

    for ii = 2:N_points
        if (isnan(r_vert(ii,1)))||(isnan(r_vert(ii-1,1)))
            continue % allow breaks in the loop
        end
        B = B + magnetostatics.B_line(r,I,r_vert(ii-1,:)',r_vert(ii,:)');
    end

end