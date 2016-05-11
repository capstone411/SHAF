
fileName = 'N:\SHAF\Capstone\data\arduino\s1_L1_G_M_Y_25_25.txt';
baselineF = 0.55;
thresholdF = 0.10;


[rC, fC, fR] = processFile(fileName, baselineF, thresholdF);
