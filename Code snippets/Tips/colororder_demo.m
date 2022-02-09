% This code was used to create the image in this Facebook post: 
% https://www.facebook.com/groups/MATLAB.KTH/permalink/3681224001998444/
x_len = 7;
x = 1:x_len;
y = peaks(x_len);

tiledlayout(1, 2, 'Padding', 'none', 'TileSpacing', 'compact'); 
nexttile
set(gca, 'colororder', 'default')
plot(x, y, 'LineWidth', 2)
title('Default color order', 'FontSize', 20)
nexttile
plot(x, y, 'LineWidth', 2)
set(gca, 'colororder', parula(x_len))
title('Parula colormap', 'FontSize', 20)