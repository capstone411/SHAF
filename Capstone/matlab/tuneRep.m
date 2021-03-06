function repArray = tuneRep(filename, baselineArray, thresholdArray, fatigueF)
% This is the function that runs processFile multiple times using different
% values for fatigueF.  

f = char(filename);

n = length(baselineArray);
m = length(thresholdArray);

repArray = zeros(n,m);

for i = 1:n
    for j = 1:m
        repArray(i,j) = processFile(f,baselineArray(i),thresholdArray(j),fatigueF);        
    end
end

repArray = uint32(repArray);