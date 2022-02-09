function b=finnishOrdering(a)
    % Sorts numbers based on alphabetical order in Finnish. Fast.
    num2names=["nolla" "yksi" "kaksi" "kolme" "neljä" "viisi" "kuusi" "seitsemän" "kahdeksan" "yhdeksän"];
    b=zeros(size(a));
    for i=0:9
        b(sort(num2names(a+1))==num2names(i+1))=i;
    end
end