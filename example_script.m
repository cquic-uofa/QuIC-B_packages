% creating coil geometry

side_length = .1757; % side length of square coil in units of 
r0 = [0;0;.04]; % position of center of square wire
direction = [0;0;1]; % unit vector that is normal to the face of the square
% direction is also defined in the right handed sense
theta = 0; % this defines the angular offset of the square
% if theta is greater than zero, then all vertices will be rotated in a right handed
% sense about the direction unit vector

vertices_top = magnetostatics.wire_square_vertices(side_length,r0,direction=direction,theta=theta);
vertices_bottom = magnetostatics.wire_square_vertices(side_length,-r0,direction=direction,theta=theta);

% vertices total contains 2 closed loops % they are joined by a row of NaN's so the algorithm does join the top and bottom loops
vertices_total = magnetostatics.concatenate_vertices(vertices_top,vertices_bottom);

% creating set of points to sample magnetic field at
N_samples = 10;
x = linspace(-.01,.01,N_samples);
y = linspace(-.01,.01,N_samples);
z = linspace(-.01,.01,N_samples);

X,Y,Z = meshgrid(x,y,z);

% r can be any shape, but last dimension must be 3
% r = zeros(1,3); % this also works
% r = zeros(10,123,32,125,123,3); % this is absurd but it still works
r = zeros(N_samples,N_samples,N_samples,3);
r(:,:,:,1) = X;
r(:,:,:,2) = Y;
r(:,:,:,3) = Z;

I = 1; % current
B = magnetostatics.B_vertices(r,I,vertices_total);
% B is of the same shape as r
% B(ii,jj,kk,1) is the x component of the magnetic field evaluated at r(ii,jj,kk,:)