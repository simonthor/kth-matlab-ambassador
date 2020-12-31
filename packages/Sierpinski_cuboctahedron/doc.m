%% Sierpinski_cuboctahedron
%
% Function to compute, display, and save a Sierpinski
% cuboctahedron at any iteration number / depth level.
%
% Author & support : nicolas.douillet (at) free.fr, 2020.
%
%% Syntax
%
% Sierpinski_cuboctahedron;
%
% Sierpinski_cuboctahedron(nb_it);
%
% Sierpinski_cuboctahedron(nb_it, option_display);
%
% [V,T] = Sierpinski_cuboctahedron(nb_it, option_display);
%
%% Description
%
% Sierpinski_cuboctahedron computes and displays the 3-level / iteration
% Sierpinski cuboctahedron included in the unit sphere.
%
% Sierpinski_cuboctahedron(nb_it) computes nb_it depth levels / iterations..
%
% Sierpinski_cuboctahedron(nb_it, option_display) displays it when
% option_display is set to logical *true/1 (default), and doesn't
% when it is set to  logical false/0.
%
% [V,T] = Sierpinski_cuboctahedron(nb_it, option_display) stores the resulting
% vertex coordinates in the array V, and the triangulation in the array T.
%
%% See also
%
% <https://fr.mathworks.com/matlabcentral/fileexchange/79152-sierpinski-octahedron Sierpinski_octahedron> |
% <https://fr.mathworks.com/matlabcentral/fileexchange/79394-sierpinski-octostar Sierpinski_octostar> |
% <https://fr.mathworks.com/matlabcentral/fileexchange/73178-sierpinski-tetrahedron Sierpinski_tetrahedron> |
% <https://fr.mathworks.com/matlabcentral/fileexchange/79511-sierpinski-triangle-2d-3d-any-triangle-shape Sierpinski_triangle>
%
%% Input arguments
%
% - nb_it : positive integer scalar double.
%
% - option_display : either logical, *true/false or numeric *1/0.
%
%% Output arguments
%
%        [ |  |  |]
% - V = [Vx Vy Vz], real matrix double, the vertex coordinates. Size(V) = [nb_vertices,3].
%        [ |  |  |]
%
%        [ |  |  |]
% - T = [T1 T2 T3], positive integer matrix double, the triangulation. Size(T) = [nb_triangles,3].
%        [ |  |  |]
%
%% Example #1
% Computes and displays the simple Sierpinski cuboctahedron at iteration 3

Sierpinski_cuboctahedron(3);

%% Example #2
% Computes, displays, and saves the Sierpinski cuboctahedron at iteration 5

[V,T] = Sierpinski_cuboctahedron(5,true);