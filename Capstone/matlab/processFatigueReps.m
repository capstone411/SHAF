% This script compiles the results of "FatigueReps" output files and
% generates a single Nx4 output CSV file, where N is size of "fatigue"
% array, column 1 is the threshold fraction use for processing, column 2 is
% oberserved rep count for data set, column 3 is the rep number that
% fatigue is first detected on, and column 4 is the difference between
% columns 2 and 3.

clc
clear

% Change the working directory
cd  N:\SHAF\Capstone\data\results

% Get list of rep counts files in working directory
fatigueRepsList = dir('*fatigueReps.csv');
p = length(fatigueRepsList);

% Add capstone matlab folder to path so new functions are recognized
path(path,'..\..\matlab')

% Observed count is needed to compare against result
load('..\arduino\observedCount.mat')

% Fatigue array sets dimensions of output
load('..\arduino\fatigue.mat')
n = length(fatigue);

% Four columns (ThresholdF, OC, FR, Diff)
m = 4;

% Create zeroed array to store loaded csv files
S = zeros(n,m,p);

for i = 1:p
    
    % Find observed count for subject and set
    [subject, set] = parseSS(fatigueRepsList(i).name);
    [found, count] = findOC(observedCount, subject, set);
    
    if found
        fprintf('%s\t\t%d\n',[subject set], count)        
        S(:,:,i) = csvread(fatigueRepsList(i).name);         
    end
    
end

result = sum(S,3);
csvwrite('fatigueRepReport2.csv', result);
