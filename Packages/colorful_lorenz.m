clf
[x, y, z] = lorenz(28, 10, 8/3, [0 1 1.05], [0 25], 0.000001);
cmap = parula(length(x)-1);
for i=1:(length(x)-1)
    line(x(i:i+1), y(i:i+1), z(i:i+1), 'Color', cmap(i, :));
end