function [subject, set] = parseSS(fileName)

f = lower(fileName);
[subject, remain] = strtok(f,'_');
[set,] = strtok(remain,'_');