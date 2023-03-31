function outputPath = generateCombPath(centerPath, combingPos, radius)
    %Even combing positions indicate left side, right side odd
    %divide combing position by 2 and round down to get how many distances
    %away from the center path
    mult = idivide( int8(combingPos), int8(2));
    radius = radius*2*double(mult);
    outputPath = zeros(1,length(centerPath));

    if rem(combingPos, 2) ~= 0
        radius = 0-radius;
    end

    %Starting Point
    outputPath(1) = centerPath(1) + radius;
    outputPath(2) = centerPath(2) + radius;
    endIndex = (length(centerPath)/2)-2;

    %Iterate through the 4 piece "dance"
    for i = 3:8:endIndex
        outputPath(i) = centerPath(i) - radius;
        outputPath(i+1) = centerPath(i+1) + radius;

        outputPath(i+2) = centerPath(i+2) - radius; 
        outputPath(i+3) = centerPath(i+3) - radius;

        outputPath(i+4) = centerPath(i+4) - radius; 
        outputPath(i+5) = centerPath(i+5) - radius;

        outputPath(i+6) = centerPath(i+6) - radius; 
        outputPath(i+7) = centerPath(i+7) + radius; 
    end
    %Final point before it turns around
    final = endIndex + 2;
    outputPath(final) = (centerPath(final) + radius);
    outputPath(final+1) = (centerPath(final+1) + radius);
    final = final +2;

    %Flip and rotate (order is important) the first half to get the second half
    for i = final:8:length(centerPath)-2
        outputPath(i) = centerPath(i) + radius;
        outputPath(i+1) = centerPath(i+1) - radius;

        outputPath(i+2) = centerPath(i+2) - radius; 
        outputPath(i+3) = centerPath(i+3) - radius;

        outputPath(i+4) = centerPath(i+4) - radius; 
        outputPath(i+5) = centerPath(i+5) - radius;

        outputPath(i+6) = centerPath(i+6) + radius; 
        outputPath(i+7) = centerPath(i+7) - radius; 
    end

    outputPath(length(centerPath)-1) = outputPath(1);
    outputPath(length(centerPath)) = outputPath(2);
    % Debug Graph
    % hold on
    %     scatter(centerPath(1:2:end), centerPath(2:2:end),'blue')
    %     scatter(outputPath(1:2:end), outputPath(2:2:end),'red')
    % hold off
end