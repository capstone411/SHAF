function [found, count] = findOC(observedCount, subject, set)

%load('..\data\arduino\observedCount.mat')
found = 0;
count = 0;

for i = 1:length(observedCount)
    
%     s = lower(observedCount(i).name);
%     [subjectT, remain] = strtok(s,'_');
%     [setT,] = strtok(remain,'_');

    [subjectT, setT] = parseSS(observedCount(i).name);
    
    if strcmp(subjectT,subject) && strcmp(setT,set)
        found = 1;
        count = observedCount(i).observed;
        break;
    end
    
end





