%% Initialize MATLAB state
clear
clc
tic

% IMPORTANT!  The working directory needs to contain the files to be
% processed.  This may change depending on which computer is running the
% code.  If this file is in the capstone\matlab directory, the correct
% relative path is capstone\data\arduino
cd C:\Users\Todd\Documents\GitHub\SHAF\Capstone\data\arduino

% Directory to store results
d = '..\results\';

% Add capstone matlab folder to path so new functions are recognized
path(path,'..\..\matlab')

% Mode switch for processing
FAST_MODE = 1;
FATIGUE_MODE = 0;
BT_MODE = 0;

% "Tuned" variables determined through other analysis
B_TUNED = 0.40;
T_TUNED = 0.50;
F_TUNED = 0.28;

% Load needed variables
load('observedCount.mat')   % array of structs w/ filename and oberved rep count
load('threshold.mat')       % array of rep threshold fractions
load('baseline.mat')        % array of rep baseline fractions
load('fatigue.mat')         % array of fatigue threshold fractions


%% Process files in working directory
% Currently, all the capstone arduino data files are saved with the '.txt'
% extension
textFileList = dir('*.txt');
n = length(textFileList);

% Create 3D array to hold fatigue results
fatigueSum = zeros(length(fatigue),4,n);
for i = 1:n
     
    % Get next file name in list
    fileName = textFileList(i).name;
    % Parse subject and set from file name    
    [sub,set] = parseSS(fileName);
    
    if FAST_MODE
        % Build file name for processFile function
        f = [pwd '\' fileName];
        % Process file
        [rc, fr] = processFile(f, B_TUNED, T_TUNED, F_TUNED);
        % Prints results to console
        fprintf('%s\t\trc: %d\t\tfr: %d\n', fileName, rc, fr);
    elseif FATIGUE_MODE
        % Build fatigue rep output file name
        fatigueFilename = [d sub '_' set '_' 'fatigueReps.csv'];
        % Process for fatigue rep detection
        outputArray = tuneFatigue(fileName, B_TUNED, T_TUNED, fatigue);
        % Add output array to fatigue sum 3D array
        fatigueSum(:,:,i) = outputArray;
        % Write fatigue rep array to result csv file
        csvwrite(fatigueFilename, outputArray);
        % DEBUG print statement
        fprintf('Finished (%d of %d)\t%s\n',i,n,fatigueFilename)
    elseif BT_MODE
        % Build rep count output file name
        repFilename = [d sub '_' set '_' 'repCounts.csv'];
        % Process for rep count
        repArray = tuneRep(fileName, baseline, threshold, F_TUNED);
        % Write rep count array to result csv file
        csvwrite(repFilename, repArray);
    end
    
end

toc
