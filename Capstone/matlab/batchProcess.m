%% Initialize MATLAB state
clear
clc
tic

% IMPORTANT!  The working directory needs to contain the files to be
% processed.  This may change depending on which computer is running the
% code.  If this file is in the capstone\matlab directory, the correct
% relative path is capstone\data\arduino
cd C:\Users\Todd\Documents\GitHub\SHAF\Capstone\data\arduino

% Add capstone matlab folder to path so new functions are recognized
path(path,'..\..\matlab')

% Load needed variables
load('observedCount.mat')       % filename of set and observed rep count
load('threshold.mat')           % 1-by-n array of threshold fractions
load('baseline.mat')            % 1-by-m array of baseline fractions

% Directory to store results
d = '..\results\';


%% Process files in working directory
% Currently, all the capstone arduino data files are saved with the '.txt'
% extension
textFileNames = dir('*.txt');

for i = 1:length(textFileNames)
    
    % Get next file name in list
    fileName = textFileNames(i).name;
    % Parse subject and set from file name    
    [sub,set] = parseSS(fileName);    
    % Build rep count output file name
    repFilename = [d sub '_' set '_' 'repCounts.csv'];
    % Process for rep count
    repArray = tuneRep(fileName, baseline, threshold);
    % Write rep count array to result csv file
    csvwrite(repFilename, repArray);
    
end

toc
