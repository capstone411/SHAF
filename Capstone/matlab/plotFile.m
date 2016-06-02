function [repCount, fatigueRep] = plotFile(fileName, ~, ~, ~)


baselineF = 0.35;
thresholdF = 0.60;
fatigueF = 0.17;

%% Open the text file.
fileID = fopen(fileName,'r');

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*30s%s%[^\n\r]';

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '',  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);    

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

% Converts strings in the input cell array to numbers. Replaced non-numeric
% strings with NaN.
rawData = dataArray{1};
for row=1:size(rawData, 1);
    % Create a regular expression to detect and remove non-numeric prefixes and
    % suffixes.
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
        result = regexp(rawData{row}, regexstr, 'names');
        numbers = result.numbers;

        % Detected commas in non-thousand locations.
        invalidThousandsSeparator = false;
        if any(numbers==',');
            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
            if isempty(regexp(thousandsRegExp, ',', 'once'));
                numbers = NaN;
                invalidThousandsSeparator = true;
            end
        end
        % Convert numeric strings to numbers.
        if ~invalidThousandsSeparator;
            numbers = textscan(strrep(numbers, ',', ''), '%f');
            numericData(row, 1) = numbers{1};
            raw{row, 1} = numbers{1};
        end
    catch me
    end
end

%% Exclude rows with non-numeric cells
J = ~all(cellfun(@(x) (isnumeric(x) || islogical(x)) && ~isnan(x),raw),2); % Find rows with non-numeric cells
raw(J,:) = [];

%% Allocate imported array to column variable names
data = cell2mat(raw(:, 1));

%% Clear temporary variables
clearvars formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me J;    

%% Remove leading 3,2,1 countdown data
data = data(4:end);

%% Variables for algorithm
ADC_BITS = 1024;
VOLTAGE_SOURCE = 5;
FATIGUE_PERCENT = fatigueF;

baseline = 10; % initial value only
threshold = 50; % initial value only    
newRep = 0;
repCount = 0;
fatigueRep = 0;
maxVoltage = 0;
currentPeakVoltage = ADC_BITS - 1;
reps = [];

%% Convert from floating-point to integer
data = min(1023, floor(data / VOLTAGE_SOURCE * ADC_BITS));

%% Plot the data
plot(data)
hold on

%% Detect reps and fatigue
for j = 1:numel(data)
    if data(j) > baseline
        newRep = 1;
        if data(j) > maxVoltage
            maxVoltage = data(j);
        end
    else
        if maxVoltage >= threshold  
            if newRep
                repCount = repCount + 1;
                reps = [reps 
                if repCount == 1;
                    % Calculate baseline and theshold on first rep
                    threshold = thresholdF * maxVoltage;
                    baseline = baselineF * maxVoltage;
                end                     
                previousPeakVoltage = currentPeakVoltage;
                currentPeakVoltage = maxVoltage;        
                maxVoltage = 0;
                newRep = 0;
                tempPercent = rpd(currentPeakVoltage,previousPeakVoltage);
                if (fatigueRep == 0) && (tempPercent > FATIGUE_PERCENT)
                   fatigueRep = repCount;
                end                  
            end       
        end
    end
end
