function [out] = hermitian_basis_Sd(d)

% Makes generalized Gell-Mann matrices for d dimensional system with
% sqrt(d) to normalize for process matrix

out = zeros(d,d,d^2-1);
for ii = 1:d-1
    out(:,:,ii) = diag(sqrt(d)*[ones(1,ii), -ii,zeros(1,d-1-ii)])./sqrt(ii+ii.^2);
    %out(:,:,ii) = diag([1, zeros(1,ii-1),1])./sqrt(ii+ii.^2);
end
s = d*(d-1)./2;
for ii = 2:d
    for jj = 1:ii-1
        n = (ii-2)*(ii-1)./2+jj+d-1;
        out(ii,jj,n) = sqrt(d)./sqrt(2);
        out(jj,ii,n) = sqrt(d)./sqrt(2);
        out(ii,jj,n+s) = sqrt(d)*1i./sqrt(2);
        out(jj,ii,n+s) = -sqrt(d)*1i./sqrt(2);
    end
end

% out(:,:,[1 3]) = out(:,:,[3 1]);
% out(:,:,[2 6]) = out(:,:,[6 2]);
% out(:,:,[5 7]) = out(:,:,[7 5]);
% out(:,:,[6 8]) = out(:,:,[8 6]);
% out(:,:,[6 7]) = out(:,:,[7 6]);
% 
% sout([1 3]) = sout([3 1]);
% sout([2 6]) = sout([6 2]);
% sout([5 7]) = sout([7 5]);
% sout([6 8]) = sout([8 6]);
% sout([6 7]) = sout([7 6]);
