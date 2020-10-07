function [iter_counts] = mandelbrot(res, iter, plot)
    complex_plane = linspace(-2,2,res) + linspace(-2i,2i,res)';
    iter_counts = zeros(size(complex_plane));
    z_values = complex_plane;
    for i=1:iter
        relevant_index = abs(z_values) < 2;
        z_values(relevant_index) = z_values(relevant_index) .^2 + complex_plane(relevant_index);
        iter_counts(relevant_index) = iter_counts(relevant_index) + 1;
    end
    if nargin > 2 && plot
        imshow(iter_counts ./ max(iter_counts, [], 'all') .* 255, jet);
        axis square;
    end
end