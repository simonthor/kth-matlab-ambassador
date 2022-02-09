function sortedNumbers = fastFinnish (numbers)
    % Sorts numbers based on alphabetical order in Finnish. Fast.
    unique_numbers = unique(numbers);
    occurences = sum(numbers == unique_numbers');
    order = [8 2 3 6 4 0 7 5 9 1];
    sortedNumbers = zeros(size(numbers));
    for 
end
