function repArray = tuneRep(filename, baselineArray, thresholdArray)

f = char(filename);

n = length(baselineArray);
m = length(thresholdArray);

repArray = zeros(n,m);

for i = 1:n
    for j = 1:m
        repArray(i,j) = processFile(f,baselineArray(i),thresholdArray(j));        
    end
end

repArray = uint32(repArray);