function [V, T] = Sierpinski_cuboctahedron(nb_it, option_display)
%% Sierpinski_cuboctahedron : function compute, display, and save
% a Sierpinski cuboctahedron at any iteration number / depth level.
%
% Author & support : nicolas.douillet (at) free.fr, 2020.
%
%
% Syntax
%
% Sierpinski_cuboctahedron;
% Sierpinski_cuboctahedron(nb_it);
% Sierpinski_cuboctahedron(nb_it, option_display);
% [V,T] = Sierpinski_cuboctahedron(nb_it, option_display);
%
%
% Description
%
% Sierpinski_cuboctahedron computes and displays the 3-level / iteration
% Sierpinski cuboctahedron included in the unit sphere.
%
% Sierpinski_cuboctahedron(nb_it) computes nb_it depth levels / iterations.
%
% Sierpinski_cuboctahedron(nb_it, option_display) displays it when
% option_display is set to logical *true/1 (default), and doesn't
% when it is set to  logical false/0.
%
% [V,T] = Sierpinski_cuboctahedron(nb_it, option_display) stores the resulting
% vertex coordinates in the array V, and the triangulation in the array T.
%
%
% Input arguments
%
% - nb_it : positive integer scalar double, the number of iterations / depth level.
% - option_display : either logical, *true/false or numeric *1/0.
%
%
% Output arguments
%
%       [ |  |  |]
% - V = [Vx Vy Vz], real matrix double, the vertex coordinates. Size(V) = [nb_vertices,3].
%       [ |  |  |]
%
%       [ |  |  |]
% - T = [T1 T2 T3], positive integer matrix double, the triangulation. Size(T) = [nb_triangles,3].
%       [ |  |  |]
%
%
% Example #1 : computes and displays the simple Sierpinski cuboctahedron at iteration 3
%
% Sierpinski_cuboctahedron(3);
%
%
% Example #2 : computes, displays, and saves the Sierpinski cuboctahedron at iteration 5
%
% [V,T] = Sierpinski_cuboctahedron(5,true);


%% Input parsing
assert(nargin > 0,'Not enough input argument.');
assert(nargin < 3,'Too many input arguments.');

if nargin > 0
    
    assert(isnumeric(nb_it) && nb_it == floor(nb_it) && nb_it >= 0,'nb_it parameter value must be numeric positive or null integer.');
    
    if nargin > 1
        
        assert(islogical(option_display) || isnumeric(option_display),'option_display parameter type must be either logical or numeric.');
        
    else
        
        option_display = true;
        
    end
    
end

warning('on');

if option_display & nb_it > 6
    
    warning('%s triangles to display ! Make sure your graphic card has enough memory.',num2str(24*12^nb_it))
    
end

warning('off');


%% Body
% Summits of original cuboctahedron (living in the unit sphere R(O,1))
V1 = [0 0 0];
V2 = [2*sqrt(2)/3 0 -4/3];
V3 = [-sqrt(2)/3 sqrt(6)/3 -4/3];
V4 = [-sqrt(2)/3 -sqrt(6)/3 -4/3];

Summit_array = [V1; V2; V3; V4];

[Vertex_array,Triangle_array,Middle_edge_array] = tetrahedron_iterate(V1,V2,V3,V4);

p = 0;

% nb_it iterations
while p ~= nb_it
        
    New_vertex_array      = repmat(Vertex_array,      [1 1 4]);
    New_summit_array      = repmat(Summit_array,      [1 1 4]);
    New_triangle_array    = repmat(Triangle_array,    [1 1 4]);
    New_middle_edge_array = repmat(Middle_edge_array, [1 1 4]);
    
    for j = 1:size(Vertex_array,3) % loop on current nb cubocta               
        
        for i = 1:4
            
            V = Summit_array(i,:,j); % current summit
            
            D = sqrt(sum((Middle_edge_array(:,:,j) - repmat(V,[6 1])).^2,2)); % distance matrix
            [~,idx] = sort(D,1);
            
            New_summit_array(:,:,4*(j-1)+i) = [V; Middle_edge_array(idx(1),:,j); Middle_edge_array(idx(2),:,j); Middle_edge_array(idx(3),:,j)];
            
            % sort New_summit_array regarding to zmax, xmax, ymax, ymin
            i_zmax = find(New_summit_array(:,3,4*(j-1)+i) == max(New_summit_array(:,3,4*(j-1)+i)),1);
            i_xmax = find(New_summit_array(:,1,4*(j-1)+i) == max(New_summit_array(:,1,4*(j-1)+i)),1);
            i_ymax = find(New_summit_array(:,2,4*(j-1)+i) == max(New_summit_array(:,2,4*(j-1)+i)),1);
            i_ymin = find(New_summit_array(:,2,4*(j-1)+i) == min(New_summit_array(:,2,4*(j-1)+i)),1);
            
            New_summit_array(:,:,4*(j-1)+i) = [New_summit_array(i_zmax,:,4*(j-1)+i);...
                                               New_summit_array(i_xmax,:,4*(j-1)+i);...
                                               New_summit_array(i_ymax,:,4*(j-1)+i);...
                                               New_summit_array(i_ymin,:,4*(j-1)+i)];
                     
        
        % Create new cubocta : vertices, triangles, middle edge
        [New_vertex_array(:,:,4*(j-1)+i),New_triangle_array(:,:,4*(j-1)+i),New_middle_edge_array(:,:,4*(j-1)+i)] = ...
            tetrahedron_iterate(New_summit_array(1,:,4*(j-1)+i),...
                                New_summit_array(2,:,4*(j-1)+i),...
                                New_summit_array(3,:,4*(j-1)+i),...
                                New_summit_array(4,:,4*(j-1)+i));                                                                          
        end
        
    end
    
    Vertex_array      = New_vertex_array;
    Summit_array      = New_summit_array;
    Triangle_array    = New_triangle_array;
    Middle_edge_array = New_middle_edge_array;
    
    p = p+1;
    
end

V = Vertex_array(:,:,1);
T = Triangle_array(:,:,1);

for k = 1: size(Vertex_array,3)
    
    T = cat(1,T,Triangle_array(:,:,k)+size(V,1));
    V = cat(1,V,Vertex_array(:,:,k));
    
end

Rmy = @(theta)[cos(theta) 0 -sin(theta);
               0          1  0;
               sin(theta) 0  cos(theta)];           


Rmz = @(theta)[cos(theta) -sin(theta) 0;
               sin(theta)  cos(theta) 0;
               0           0          1];

Vs = cat(2,-V(:,1),V(:,2:3));
Vr1 = (Rmy(-acos(-1/3))*Vs')';
Vr2 = (Rmz(2*pi/3)*Vr1')';
Vr3 = (Rmz(-2*pi/3)*Vr1')';

Tr1 = T + size(V,1);
Tr2 = T + 2*size(V,1);
Tr3 = T + 3*size(V,1);

V = cat(1,V,Vr1,Vr2,Vr3);
T = cat(1,T,Tr1,Tr2,Tr3);

% Top tetrahedra
V2 = -V;
T2 = T + size(V,1);
V = cat(1,V,V2);
T = cat(1,T,T2);

% Remove duplicated vertices
[V,T] = remove_duplicated_vertices(V,T);

% Remove duplicated triangles
T = unique(sort(T,2),'rows','stable');

%  Display
if option_display
    
    figure;    
    trisurf(T,V(:,1),V(:,2),V(:,3),'EdgeColor',[0 0 1]), shading interp, hold on;
    colormap(rainbow);
    camlight('left');
    axis equal, axis tight;
    view(-43.7058,21.3485);
    
end

end % Sierpinski_cuboctahedron


%% tetrahedron_iterate subfunction
function [M, T, C] = tetrahedron_iterate(V1, V2, V3, V4)

% Tetrahedron isobarycentre
X = 0.25 * (V1 + V2 + V3 + V4); 

M123 = [V1; V2; V3];
T = [1,2,3];

% Translation vector
tv = repmat(X,[size(M123,1),1]);

M134 = ([-0.5 -0.5*sqrt(3) 0; 0.5*sqrt(3) -0.5 0; 0 0 1]*(M123-tv)' + tv')';
M142 = ([-0.5 -0.5*sqrt(3) 0; 0.5*sqrt(3) -0.5 0; 0 0 1]*(M134-tv)' + tv')';

M234 = [V2; V3; V4];

C = 0.5 * [V1+V2; V1+V3; V1+V4; V2+V3; V2+V4; V3+V4];
M = [M123; M134; M142; M234];

% Triplet indices list 
T = [T;
     T +   repmat(size(M123,1),[size(T,1) size(T,2)]);...
     T + 2*repmat(size(M123,1),[size(T,1) size(T,2)]);...
     T + 3*repmat(size(M123,1),[size(T,1) size(T,2)])];

end % tetrahedron_iterate


%% remove_duplicated_vertices subfunction
function [V_out, T_out] = remove_duplicated_vertices(V_in, T_in)


tol = 1e4*eps;
[V_out,~,n] = uniquetol(V_in,tol,'ByRows',true);
T_out = n(T_in);


end % remove_duplicated_vertices