clc
clear

% Change the working directory
cd C:\Users\Todd\Documents\GitHub\SHAF\Capstone\data\results

% Get list of rep counts files in working directory
repCountsList = dir('*repCounts.csv');
p = length(repCountsList);

% Add capstone matlab folder to path so new functions are recognized
path(path,'..\..\matlab')

% Observed count is needed to compare against result
load('..\arduino\observedCount.mat')

% Baseline and threshold set n and m dimensions of result
load('..\arduino\baseline.mat')
n = length(baseline);
load('..\arduino\threshold.mat')
m = length(threshold);

% Create zeroed array to store loaded csv files
S = zeros(n,m,p);

% Different count variables for debugging
exactMatch = 0;
pmOne = 0;
pmTwo = 0;
pmThree = 0;
pmFive = 0;

for i = 1:p
    
    % Find observed count for subject and set
    [subject, set] = parseSS(repCountsList(i).name);
    [found, count] = findOC(observedCount, subject, set);
    
    if found
        fprintf('%s\t\t%d\n',[subject set], count)        
        S(:,:,i) = csvread(repCountsList(i).name);
        S(:,:,i) = count - S(:,:,i); 
    end
    
end

result = sum(S,3);
csvwrite('repDiffReport.csv', result); 
