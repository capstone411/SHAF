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

% Create zeroed array to store loaded csv files
S = zeros(16,4,p);

for i = 1:p
    
    % Find observed count for subject and set
    [subject, set] = parseSS(fatigueRepsList(i).name);
    [found, count] = findOC(observedCount, subject, set);
    
    if found
        fprintf('%s\t\t%d\n',[subject set], count)        
        S(:,:,i) = csvread(fatigueRepsList(i).name);
        %S(:,:,i) = abs(count - S(:,:,i)); 
    end
    
end

result = sum(S,3);
csvwrite('fatigueRepReport2.csv', result);
