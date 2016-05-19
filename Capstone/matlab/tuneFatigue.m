function outputArray = tuneFatigue(fileName, baseline, threshold, ...
    fatigueThresholdArray)

n = length(fatigueThresholdArray);

outputArray = zeros(n,4);

for i = 1:n
    outputArray(i,1) = fatigueThresholdArray(i);
    [outputArray(i,2), outputArray(i,3)] =  processFile(fileName, ...
        baseline, threshold, fatigueThresholdArray(i));
    outputArray(i,4) = outputArray(i,3) - outputArray(i,2);
end
        




