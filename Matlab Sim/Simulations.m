clear
clc
length = 18;
display = false;
radius = 0.25;

%% Time vs Number of Bots, Number of Chunks Constant: Checkerboard vs. Comb
% Warning: This simulation takes a while (~10 minutes to complete)
chunkSize = 4;
i = 1;

%Run Simulations 
for numBots = 3:2:15
    comb{i} = CombingPattern(length, numBots, radius, display);
    checker{i} = CheckerboardPattern(length, numBots, radius, chunkSize, display);
    i = i+1;
end

%Process Data
numBots = 3:2:15;
for j =1:i-1
    checkerTime(j) = cell2mat(checker{j}(1));
    combTime(j) = cell2mat(comb{j}(1));
    % header = ['Number of bots: ', numBots(j), newline, 'Length Of Field: ' ,num2str(length), 'meters', newline, 'Scan Radius: ', num2str(radius), ' meters'];
    % disp(header)
    % output = ['Checkerboard Pattern Time (In Minutes) ', num2str(cell2mat(checker{j}(1))), newline 'Combing Pattern Time (In Mintues) ', num2str(cell2mat(comb{j}(1)))];
    % disp(output)
end

%Plot Results
figure
y = [checkerTime;combTime];
bar(numBots, y);
title("Time vs Number of Bots: Number of Chunks Constant");
sub1 = strcat('Length Of Field: ' ,num2str(length), 'm       ', 'Scan Radius: ', num2str(radius), ' m');
subtitle(sub1);
legend("Checkerboard Pattern","Combing Pattern" );

%% Checkerboard Time vs Number of Chunks, Number of Bots Constant  
botcount = 3;
i = 1;
%How does the checker time change as the number of chunks change, and the number of bots stay the same?
for chunkSize = 2:6
    comb{i} = CombingPattern(length, numBots, radius, display);
    checker{i} = CheckerboardPattern(length, numBots, radius, chunkSize, display);
    i = i+1;
end




