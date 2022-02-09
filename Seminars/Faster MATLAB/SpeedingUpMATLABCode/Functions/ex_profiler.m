[X,Y] = meshgrid(-2:.2:2);                                

Z = X .* exp(-X.^2 - Y.^2);

P = xcorr2(X,ones(10000,1000));

surf(X,Y,Z)