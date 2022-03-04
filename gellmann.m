% def gen_basis_new_order(d): # try to loop differently so that order in nicer # do _h_l[0,0] first, then all _f_jk, then rest of _h_l then identity
% 	M = np.zeros((d*d,d,d),dtype='complex128')
% 	# M[0,:,:] = _h_l(d-2)/np.sqrt(2)
% 	c = 0
% 	for i in range(d):
% 		for j in range(i):
% 			M[c,:,:] = _f_jk(i,j,d)/np.sqrt(2)
% 			c += 1
% 			M[c,:,:] = _f_jk(j,i,d)/np.sqrt(2)
% 			c += 1

% 	for k in range(d-1):
% 		M[c] = _h_l(k,d)/np.sqrt(2)
% 		c += 1
% 	M[c,:,:] = np.eye(d)/np.sqrt(d) # last
% 	return M



classdef gellmann

	methods (Access=private,Static)
		function E = E_d(jj,kk,d)
			E = zeros(d);
			E(jj+1,kk+1) = 1;
		end

		function f = f_jk(jj,kk,d)
			if jj<kk
				f = gellmann.E_d(jj,kk,d)+gellmann.E_d(kk,jj,d);
				return
			elseif jj>kk
				f = -1j*(gellmann.E_d(jj,kk,d)-gellmann.E_d(kk,jj,d));
				return
			% else
			% 	eidType = 'mustBeHalfInteger:notHalfInteger';
			% 	msgType = 'Input must be integer or half integer.';
			% 	throwAsCaller(MException(eidType,msgType))
			end
		end

		function h = h_l(l,d)
			h = zeros(d,d);
			for jj = 0:l
				h = h + gellmann.E_d(jj,jj,d);
			end
			h = h - (l+1)*gellmann.E_d(l+1,l+1,d);
			h = h*sqrt(2/((l+1)*(l+2)));
		end

		function vec = Op2Vec(op)
			vec = op(:);
		end


	end

	methods (Access=public,Static)
		
		function M = gen_basis(d) % # try to loop differently so that order in nicer # do _h_l[0,0] first, then all _f_jk, then rest of _h_l then identity
			M = zeros(d,d,d*d);
			M(:,:,1) = eye(d)/sqrt(d);
			for ii = 0:(d-1)
				for jj = 0:(d-1)
					if ii ~= jj
						M(:,:,d*ii+jj+2) = gellmann.f_jk(ii,jj,d)/sqrt(2);
					end
					if ii == jj
						if ii~=(d-1)
							M(:,:,d*ii+jj+2) = gellmann.h_l(ii,d)/sqrt(2);
						else
							continue
						end
					end
				end
			end
		end

		function M = gen_basis_super(d)
			M = zeros(d*d);
			M(:,1) = gellmann.Op2Vec(eye(d)/sqrt(d));
			for ii = 0:(d-1)
				for jj = 0:(d-1)
					if ii ~= jj
						M(:,d*ii+jj+2) = gellmann.Op2Vec(gellmann.f_jk(ii,jj,d)/sqrt(2));
					end
					if ii == jj
						if ii~=(d-1)
							M(:,d*ii+jj+2) = gellmann.Op2Vec(gellmann.h_l(ii,d)/sqrt(2));
						else
							continue
						end
					end
				end
			end

		end


		% # create function to decompose into gellmann vector
		function r = decompose(A,M)
			[d,~] = size(A); % # assume square
			if nargin<2
				M = gellmann.gen_basis(d);
			end
			% else
			% 	assert M.shape[0]==d**2, 'Dimension of M does not match input'
			r = zeros(d^2,1);
			% # r[0] = np.real(np.trace(A))
			for ii = 1:d^2
				r(ii) = real(trace(A*M(:,:,ii)));
			end
		end

		function r = decompose2(A,M_sup)
			[d,~] = size(A); % # assume square
			if nargin<2
				M_sup = gellmann.gen_basis_super(d);
			end
			
			r = real(M_sup'*A(:));%    zeros(d^2,1);
			
			% for ii = 1:d^2
			% 	r(ii) = real(trace(A*M(:,:,ii)));
			% end

		end

		function A = compose(r,M)
			[d,~] = size(r);
			d = sqrt(d);
			if nargin<2
				M = gellmann.gen_basis(d);
			end
			% else:
			% 	assert M.shape[0]==r.shape[0], 'Dimension of M does not match input'
			A = zeros(d);
			for ii = 1:d^2
				A = A + M(:,:,ii)*r(ii);
			end

		end

		function A = compose2(r,M)
			[d,~] = size(r);
			d = sqrt(d);
			if nargin<2
				M = gellmann.gen_basis_super(d);
			end
			% else:
			% 	assert M.shape[0]==r.shape[0], 'Dimension of M does not match input'
			A = M*r;
			A = reshape(A,d,d);
			
		end

	end

end