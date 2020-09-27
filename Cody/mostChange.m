function [b] = mostChange(a)
    money = sum([a; zeros([1 4])] .* [0.25 0.05 0.1 0.01], 2);
    [~, b] = max(money);
end
