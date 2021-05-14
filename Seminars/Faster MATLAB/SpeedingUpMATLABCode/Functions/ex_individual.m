function a = ex_individual(M,i)


if i == 45
    error("We've created an example error here");
else
    a = max(eig(rand(M)));
end

end