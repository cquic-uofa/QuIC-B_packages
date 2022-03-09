function [ subspace_proj ] = bgrape_make_proj( subspace_vec, total_dim)

    subspace_dim = length(subspace_vec);
    
    subspace_proj = zeros(total_dim);
    
    for a = 1:subspace_dim
        b = subspace_vec(a);
        subspace_proj(b,b) = 1;
    end

end

