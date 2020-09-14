f = @(x, y) sin(x.^2)+y.^2;
[x, y] = meshgrid(-5:0.1:5);
z = f(x, y);
imshow(z - min(z) ./ (max(z) - min(z)) .*255, parula)

