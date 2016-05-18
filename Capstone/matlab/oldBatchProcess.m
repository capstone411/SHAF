tic
clc
clear








% Defining "Constants"
ADC_BITS = 1024;
VOLTAGE_SOURCE = 5;
FATIGUE_PERCENT = 0.17;
BASELINE = 50; 

%% Create string array of text files name in the folder
textFileNames = dir('*.txt');

%% DEBUG VARIABLES
dataZeros = zeros(length(textFileNames),1);
dataMeans = zeros(length(textFileNames),1);
dataMedians = zeros(length(textFileNames),1);
dataMaximums = zeros(length(textFileNames),1);
dataMinimums = zeros(length(textFileNames),1);
dataReps = zeros(length(textFileNames),1);
dataFatigued = zeros(length(textFileNames),1);

%% Loop to process all raw Arduino data 
for i = 1:length(textFileNames)

    % Clear previous plot
    clf

    %% Look at next text file in directory
    filename = textFileNames(i).name;
    
    %% INSERT PROCESSFILE()
    
    %% Read columns of data as strings:
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%*30s%s%[^\n\r]';

    %% Open the text file.
    fileID = fopen(filename,'r');

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

    %% Convert from floating-point to integer
    data = min(1023, floor(data / VOLTAGE_SOURCE * ADC_BITS));
        
    %% Variables for algorithm
    repEdge = 0;  % 1=pos_edge; 0=neg_edge 
    repCount = 0;
    maxVoltage = 0;
    currentPeakVoltage = ADC_BITS - 1;
    previousPeakVoltage = ADC_BITS - 1;
    tempPercent = 0.0;
    fatigueCount = 0;
    fatigueFlag = 0;
    repFatigueDetectedOn = 0;
    sampleFatigueDetectedOn = 0;
    
    % Quasi-Constant, needs calibration for each subject.
    % Choosing value for now until programmatic solution developed
    THRESHOLD_VOLTAGE = 51;

    %% Detect reps and fatigue
    for j = 1:numel(data)
        if data(j) > BASELINE
            repEdge = 1;
            if data(j) > maxVoltage
                maxVoltage = data(j);
            else
                continue
            end
        else
            if maxVoltage >= THRESHOLD_VOLTAGE  
                if repEdge
                     repCount = repCount + 1;
                     plot(j, data(j), 'rs')
                    % Using first rep to set threshold voltage by                 
                    % dividing the first max voltage by sqrt(2)
                    if repCount == 1;
                        THRESHOLD_VOLTAGE = floor(maxVoltage/1.4142);
                    end                     
                    repEdge = 0;
                    maxVoltage = 0;
                end          
                previousPeakVoltage = currentPeakVoltage;
                currentPeakVoltage = maxVoltage;
                tempPercent = (currentPeakVoltage/previousPeakVoltage) - 1;
                if tempPercent > FATIGUE_PERCENT
                    repFatigueDetectedOn = repCount;
                    sampleFatigueDetectedOn = j;
                    fatigueFlag = 1;
                end
            else
                continue
            end
        end
    end    

    %% DEBUG: Looking at the mean and median of each data set
    dataMeans(i) = mean(data);
    dataMedians(i) = median(data);
    dataMaximums(i) = max(data);
    dataMinimums(i) = min(data);
    dataReps(i) = repCount;
    dataFatigued(i) = fatigueFlag;
    
    %% Print results
%     fprintf('%s\n',filename)
%     fprintf('\tReps detected:\t%d\n',repCount)
%     fprintf('\tFatigue detected?\t')
%     if fatigueFlag == 1
%         fprintf('Yes, on rep %d\n', sampleFatigueDetectedOn)
%     else
%         fprintf('No\n')
%     end
% %     fprintf('\tMean voltage:\t%f\n',mean(data))
% %     fprintf('\tMedian voltage:\t%f\n',median(data))
%     fprintf('\n')

    %% DEBUG: Looping through datasets looking for stuff
%    fprintf('\tlast 3: [%f %f %f]\n', data(end-2),data(end-1),data(end))
%    fprintf('\tmean: %f\n', mean(data))
%     if DEBUG_ON
%         zeroCount = 0;
%         sampleCount = numel(data);
%         for j = 1:sampleCount
%            if data(j) == 0
%                zeroCount = zeroCount + 1;
%            end
%         end
%         percentZero = zeroCount / sampleCount;
%         dataZeros(i) = percentZero;
%         fprintf('\tNo. of zero:\t%d\n',zeroCount)
%         fprintf('\tTotal samples:\t%d\n',sampleCount)
%         fprintf('\tPERCENT ZEROS:\t%f\n',percentZero)
%    end

     %% DEBUG: Looking at first three elements for 1,2,3 pattern
%     testArray = [3.0; 2.0; 1.0];
%     matchCount = 0;
%     if isequal (testArray, data(1:3))
%         fprintf('is a match\n')
%     else
%         fprintf('is not a match\n')
%     end 
    
end

fprintf('END OF REPORT\n')
toc
