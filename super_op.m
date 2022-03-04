classdef super_op
% add functionality to generate Gellman change of basis
% Op2Vec(op)
% Vec2Op(vec)
% Op2DVec(op)
% DVec2Op(dvec)
% AxAd(A)

methods (Static)
    function vec = Op2Vec(op)
        vec = op(:);
    end
    function op = Vec2Op(vec)
        N = sqrt(length(vec)); % should error check this
        if N ~= floor(N)
            error('Vector length must be perfect square')
        end
        op = reshape(vec,N,N);
    end
    function dvec = Op2DVec(op)
        dvec = op(:)';
    end
    function op = DVec2Op(dvec)
        N = sqrt(length(dvec)); % should error check this
        if N ~= floor(N)
            error('Dual vector length must be perfect square')
        end
        op = reshape(dvec',N,N);
    end
    function M = AxAd(A)
        % A is (dim,dim)
        % M is (dim^2,dim^2)
        [~,dim] = size(A);
        M = zeros(dim^2,dim^2);
        for ii = 0:(dim^2-1)
            for jj = 0:(dim^2-1)
                M(jj+1,ii+1) = A(floor(jj/dim)+1,floor(ii/dim)+1)'*A(mod(jj,dim)+1,mod(ii,dim)+1);
            end
        end
    end
end

end