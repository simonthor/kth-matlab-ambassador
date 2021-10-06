function b=finnishOrdering(a)
    % Sorts numbers based on alphabetical order in Finnish. Fast.
    num2names=["nolla" "yksi" "kaksi" "kolme" "nelj�" "viisi" "kuusi" "seitsem�n" "kahdeksan" "yhdeks�n"];
    b=zeros(size(a));
    for i=0:9
        b(sort(num2names(a+1))==num2names(i+1))=i;
    end
end