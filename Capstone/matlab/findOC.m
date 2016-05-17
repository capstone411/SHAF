function [found, count] = findOC(subject, set)

load('observedCount.mat')
found = 0;
count = 0;

for i = 1:length(observedCount)

    s = lower(observedCount(i).name);
    [subjectT, remain] = strtok(s,'_');
    [setT,] = strtok(remain,'_');
    
    if strcmp(subjectT,subject) && strcmp(setT,set)
        found = 1;
        count = observedCount(i).observed;
        break;
    end
    
end





