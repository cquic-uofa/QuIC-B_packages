function [out] = hermitian_basis_S(d)

% Makes generalized Gell-Mann matrices on d dimensional system

out = zeros(d,d,d^2-1);
for ii = 1:d-1
    out(:,:,ii) = diag([ones(1,ii), -ii,zeros(1,d-1-ii)])./sqrt(ii+ii.^2);
    %out(:,:,ii) = diag([1, zeros(1,ii-1),1])./sqrt(ii+ii.^2);
end
s = d*(d-1)./2;
for ii = 2:d
    for jj = 1:ii-1
        n = (ii-2)*(ii-1)./2+jj+d-1;
        out(ii,jj,n) = 1./sqrt(2);
        out(jj,ii,n) = 1./sqrt(2);
        out(ii,jj,n+s) = 1i./sqrt(2);
        out(jj,ii,n+s) = -1i./sqrt(2);
    end
end
