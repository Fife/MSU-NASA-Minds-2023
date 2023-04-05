function output = CheckerboardPattern(FieldLength, numBots, radius, chunkSize, display)
    clc
    %Checkerboard Scanning Setup
    %How big in meters is the field length
    
    %How many Robots?
    %How many squares shall the field be divided in?
    
    %Robot Scanning Radius
    r = radius;
    
    %Center Coordingate and Chunk Length
    centerCoord = [0,0];
    chunkLen = FieldLength/chunkSize;
    
    %Map creation
    chunk = Chunk(FieldLength,FieldLength,chunkSize,centerCoord);
    
    %Create the field
    fieldStatus = repelem(0, chunkSize*chunkSize);
    fieldIndex = 1;
    
    %Create the robots
    bots = [];
    for i = 1: numBots
        var = Tellus;
        [var, fieldStatus] = var.init(chunk(1:4:end), chunkLen, [-FieldLength/2,-FieldLength/2], i, r, fieldStatus);
        bots = [bots, var];
    end
    
    %Counter for simulation timeout
    counter = 0;
    thresh = inf;
    %Run the checkerboard cooperative algorithm
    while sum(fieldStatus) ~= length(fieldStatus)*2
        for i = 1: numBots
           [bots(i), fieldStatus] = bots(i).step(fieldStatus);
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
    displacement = [];
    for i = 1 :length(bots)
        displacement(i) = (length(cell2mat(bots(i).data))*bots(i).scanRate*bots(i).velocity);
    end
    output = [time_elapsed, {displacement}];
    % %Total coverage
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
    
    %Display each point the rover passed through
    if display == true
        %Setup Display
        figure; axis square; 
        set(gca,'XLim',[-(FieldLength/2) FieldLength/2], 'YLim', [-FieldLength/2 FieldLength/2]);
        
        % Draw the paths of all the Bots
        A = cell2mat(chunk);
        x = A(1:2:end);
        y = A(2:2:end);
        scatter(x,y)
        
        %Precalculated Circle 
        th = 0:pi/50:2*pi;
        x_circle = r * cos(th);
        y_circle = r * sin(th);
        
        %Create the Robot objects on screen
        for i = 1 : numBots
            pointArr(i) = rectangle( 'Parent', gca, 'Position', [-5, -5, .1, .1], 'Curvature', [1 1] );
        end
        
        dataMatrices= [];
        %Create the Robot objects on screen
        for i = 1 : numBots
            pointArr(i) = rectangle( 'Parent', gca, 'Position', [-5, -5, .1, .1], 'Curvature', [1 1] );
            dataMatrices(i) = length(cell2mat(bots(i).data));
        end
        
        [maxFrames, maxIndex] = max(dataMatrices);
        for i = 1 : numBots
            if i ~= maxIndex
                x = bots(i).data(end-1);
                y = bots(i).data(end);
                frameDifference = round((maxFrames-(length(bots(i).data)))/2);
        
                bots(i).data = [bots(i).data, repmat([x,y], 1, frameDifference)];
            end
        end
        
        vid = VideoWriter('CheckerboardPattern.avi');
        vid.Quality = 100;
        vid.FrameRate = 30;
        open(vid);
        %Generate the frames for each robot
        
        for frameNr = 1 :2:maxFrames/2
            hold on
            for j = 1 : numBots
                set(pointArr(j), 'Position', [bots(j).data{frameNr}(1), bots(j).data{frameNr}(2), r, r]);
                xc_temp = x_circle + bots(j).data{frameNr}(1);
                yc_temp = y_circle + bots(j).data{frameNr}(2);
                plot(xc_temp, yc_temp);   
                fill(xc_temp, yc_temp, j)
            end
            writeVideo(vid, getframe(gcf));
            hold off
        end
        close(vid);
        winopen('CheckerboardPattern.avi')
    end

end
















