function [subject, set] = parseSS(fileName)
% This function parses out the subject and set values from data file names

f = lower(fileName);
[subject, remain] = strtok(f,'_');
[set,] = strtok(remain,'_');