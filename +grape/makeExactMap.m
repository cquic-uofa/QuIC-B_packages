function [exact_map] = makeExactMap(opt_params)
%Calculates the exact map between the target and the waveform unitary
%   The waveform unitary (A) and the target unitary (B) should have the
%   same eigenvalues (modulo some global phase).  This code calculates the
%   map between these two unitaries by associating the appropriate
%   eigenvectors.


    % uni_target = exact_map'*uni_final*exact_map

    % A is the waveform eigenstate matrix
    [A_vecs,A_vals] = eig(opt_params.uni_final);
    
    % A is the target eigenstate matrix
    [B_vecs,B_vals] = eig(opt_params.target_uni);
    
    
    % sort eigenvalues for proper transformation
    
    [~,Aindex] = sort(angle(diag(A_vals)));
    [~,Bindex] = sort(angle(diag(B_vals)));
    
    A_vecs = A_vecs(:,Aindex);
    B_vecs = B_vecs(:,Bindex);
    
    maxtest = 0;
    
    % Though the eigenvectors have been arranged in order of their
    % eigenphases, there may still be a global phase difference between
    % them.  The following code rotates through associating each eigenvalue
    % in A with the eigenvalues in B (but keeping the order in each
    % constant respectively).  The map with the greatest fidelity is saved.
    for aa = 1:opt_params.subspace_dim
        
        if aa == 1
            Aindex_mod = [1:16];
        else
            Aindex_mod = Aindex_mod+1;
        end
        
        for bb = 1:length(Aindex_mod)
            if Aindex_mod(bb) == 17
                Aindex_mod(bb) = 1;
            end
        end
        
        map = A_vecs(:,Aindex_mod) * ctranspose(B_vecs);
        
        test = ((1/opt_params.subspace_dim)^2) * abs(trace(ctranspose(map*opt_params.target_uni*ctranspose(map))*opt_params.uni_final))^2;
        
        if maxtest < test
            maxtest = test;
            exact_map = map;
        end
        
    end
    
    

end

