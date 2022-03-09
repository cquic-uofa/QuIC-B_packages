function [ fid ] = bgrape_mat_fid_iso( iso_1, iso_2, subspace_dim )

fid = (1/subspace_dim^2) * abs( trace(ctranspose(iso_1)*iso_2) )^2;

end

