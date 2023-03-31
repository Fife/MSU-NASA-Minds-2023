function output = CombingPattern(fieldLength, numBots, radius, display)
    clc
    
    %Combing Scanning Setup
    %How big in meters is the field length
    %How many Robots?
    %Robot Scanning Radius 
    %Center Coordingate and Chunk Length
    centerCoord = [0,0];

    spawnCoord = [-(fieldLength/2),-(fieldLength/2)];
    startCoord = [-(fieldLength/2),-(fieldLength/2)];
    fieldStatus = 0;
    
    for i = 1 : numBots
        bots(i) = Tellus; 
        bots(i) = bots(i).combInit(fieldStatus, spawnCoord, startCoord, fieldLength - numBots*radius, radius, numBots, i);
    end
    
    fieldStatus = 0;
    counter = 0;
    thresh = inf;
    %Run Simulation
    while sum(fieldStatus) ~= numBots*2
        for i = 1: numBots
           [bots(i), fieldStatus] = bots(i).combStep(fieldStatus);
        end
        counter = counter +1;
        if counter>thresh
            break;
        end
    end
    
    %Calculate Statistics 
    time_elapsed = counter * bots(1).scanRate;
    
    %Display statistics
    %Overall Displacement
    displacement = []
    for i = 1 :length(bots)
        displacement(i) = (length(cell2mat(bots(i).data))*bots(i).scanRate*bots(i).velocity);
    end
    output = [time_elapsed, {displacement}];

    
    %Total coverage
    % area = 0;
    % for i = 1 :length(bots)
    %     disp("Total Area Coverage of rover")
    %     disp(i)
    %     disp(length(cell2mat(bots(i).data))*r)
    %     area = area+length(cell2mat(bots(i).data))*r*bots(i).scanRate*bots(i).velocity;
    % end
    % disp("Total Area Coverage of all rovers")
    % disp(area)
    % disp("Percentage of Coverage")
    % disp(area/(FieldLength^2))


    if display == true
        %Display animation
        %Setup Display
        figure; axis square; 
        set(gca,'XLim',[-(fieldLength/2) fieldLength/2], 'YLim', [-fieldLength/2 fieldLength/2]);
        
        % Draw the paths of all the Bots
        
        %Precalculated Circle 
        th = 0:pi/50:2*pi;
        x_circle = radius * cos(th);
        y_circle = radius * sin(th);
        
        dataMatrices= [];
        %Create the Robot objects on screen
        for i = 1 : numBots
            pointArr(i) = rectangle( 'Parent', gca, 'Position', [-5, -5, .1, .1], 'Curvature', [1 1] );
            dataMatrices(i) = length(cell2mat(bots(i).data));
        end
        
        minFrames = max(dataMatrices);
        
        vid = VideoWriter('CombingPattern.avi');
        vid.Quality = 100;
        vid.FrameRate = 30;
        open(vid);
        %Generate the frames for each robot
        
        for frameNr = 1 :2:minFrames/2
            hold on
            for j = 1 : numBots
                set(pointArr(j), 'Position', [bots(j).data{frameNr}(1), bots(j).data{frameNr}(2), radius, radius]);
                xc_temp = x_circle + bots(j).data{frameNr}(1);
                yc_temp = y_circle + bots(j).data{frameNr}(2);
                circles = plot(xc_temp, yc_temp);   
                fill(xc_temp, yc_temp, j)
            end
            writeVideo(vid, getframe(gcf));
            hold off
        end
        close(vid);
        winopen('CombingPattern.avi')
    end
end
