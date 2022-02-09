function sOut = scrambleText(sIn)
%Cody challenge Problem 88
%   reverses the order of all letters, except the first and last in each
%   word.
    splitS = strsplit(sIn, ' ');
    
    sLen = length(splitS);
    sOut = cell(sLen);
    for i = 1:sLen
        word = strcat(splitS{i, 1}, reverse(splitS{i, 2:end-1}), splitS{i, end});
        disp(word);
        sOut(i) = word;
    end
    sOut = join(sOut);
end

