function vertices_concat = concatenate_vertices(vertices)
% Concatenates a set of vertices together inserting a row of NaNs a the correct 
% positions to indicate a break in the loop
%
% Arguments (Repeating)
%    vertices  (...,3) double : array containing a set of vertices defining a closed loop
%
    arguments (Repeating)
        vertices (:,3) double
    end
    N_tot = 0;
    for vert = vertices
        N_tot = N_tot + size(cell2mat(vert),1) + 1;
    end
    N_tot = N_tot - 1; % only count joins between closed loops

    vertices_concat = zeros(N_tot,3);
    ind = 1;
    for vert = vertices
        vert = cell2mat(vert);
        N = size(vert,1);
        vertices_concat(ind:(ind+N-1),:) = vert;
        ind = ind + N;
        if ind < N_tot
            vertices_concat(ind,:) = NaN; % this marks the boundaries between closed loops
            ind = ind + 1;
        end
    end

end