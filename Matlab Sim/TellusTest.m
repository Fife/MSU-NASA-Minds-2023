clc
%Checkerboard Scanning Setup
%How big in meters is the field length
FieldLength = 5;

%How many Robots?
numBots = 3;
%How many squares shall the field be divided in?
chunkSize = 4;

%Robot Scanning Radius
r = 0.075;

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
    [var, fieldStatus] = var.init(chunk(1:4:end), chunkLen, [-3,-3], i, r, fieldStatus);
    bots = [bots, var];
end

%Counter for simulation timeout
counter = 0;
thresh = 24000;

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

%Display statistics
%Overall Displacement
for i = 1 :length(bots)
    disp("Total Displacement of rover")
    disp(i)
    disp(length(cell2mat(bots(i).data))*bots(i).scanRate*bots(i).velocity)
end

%Total coverage
area = 0;
for i = 1 :length(bots)
    disp("Total Area Coverage of rover")
    disp(i)
    disp(length(cell2mat(bots(i).data))*2*r)
    area = area+length(cell2mat(bots(i).data))*2*r*bots(i).scanRate*bots(i).velocity;
end
disp("Total Area Coverage of all rovers")
disp(area)

disp("Percentage of Coverage")
disp(area/(FieldLength^2))

%Display each point the rover passed through

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

%Generate the frames for each robot
for frameNr = 1 :2:length(cell2mat(bots(1).data))
    hold on
    for j = 1 : numBots
        set(pointArr(j), 'Position', [bots(j).data{frameNr}(1), bots(j).data{frameNr}(2), .3, .3]);
        hold on
            xc_temp = x_circle + bots(j).data{frameNr}(1);
            yc_temp = y_circle + bots(j).data{frameNr}(2);
            circles = plot(xc_temp, yc_temp);   
            fill(xc_temp, yc_temp, j)
    end
    hold off
  frames(frameNr) = getframe;
end













% %Precalculated Circle 
% th = 0:pi/50:2*pi;
% x_circle = r * cos(th);
% y_circle = r * sin(th);
% 
% while sum(fieldStatus) ~= chunkSize*chunkSize
%     path = GeneratePath(startPoints{fieldIndex}, chunkLen, chunkLen/granularity, 0);
% 
%     %Iterate through all of the points on the path 
%     for i = 1:2:length(path)-2 
%         x = [path(i) path(i+2)];
%         y = [path(i+1) path(i+3)];
% 
%         % Calculate the trajectory of Each Bot by linear interpolation of the x and y coordinate.
%         trajectory = [linspace(x(1),x(2),numSteps); linspace(y(1),y(2),numSteps)];
%         % Make figure with axes.
% 
%         % Draw All the Bots
%         for frameNr = 1 : numSteps
%             for j = 1 : numBots
%                 set(botArray(j), 'Position', [trajectory(1,frameNr), trajectory(2,frameNr), .3, .3]);
%                 hold on
%                 xc_temp = x_circle + trajectory(1,frameNr);
%                 yc_temp = y_circle + trajectory(2,frameNr);
%                 circles = plot(xc_temp, yc_temp);   
%                 fill(xc_temp, yc_temp, "b")
%                 hold off
%             end
% 
%           frames(frameNr) = getframe;
%         end
%     end
% 
%     %Increment the Field Status
%     fieldStatus(fieldIndex) = true;
% 
%     %Choose Next Field Index 
%     currentPoint = [x(2), y(2)];
%     distances = [];
%     for i =1:length(fieldStatus)
%         dist = inf;
%         if (fieldStatus(i) == false)
%             dist = norm(currentPoint - startPoints{i});
%         end
%         distances = [distances, dist];
%         [Min, MinIndex] = min(distances);
%     end
%     fieldIndex = MinIndex;
% 
%     %Travel To Next Starting Point
%     x = [x(2) startPoints{fieldIndex}(1)];
%     y = [y(2) startPoints{fieldIndex}(2)];
%     trajectory = [linspace(x(1),x(2),numSteps); linspace(y(1),y(2),numSteps)];
% 
%     % Draw the bots
%     for frameNr = 1 : numSteps
%         for j = 1 : numBots
%             set(botArray(j), 'Position', [trajectory(1,frameNr), trajectory(2,frameNr), .3, .3]);
%             hold on
%             xc_temp = x_circle + trajectory(1,frameNr);
%             yc_temp = y_circle + trajectory(2,frameNr);
%             circles = plot(xc_temp, yc_temp);   
%             fill(xc_temp, yc_temp, "b")
%             hold off
%         end
%       frames(frameNr) = getframe;
%     end
% 
% end

% function CoopMappingAlgorithmStep()
%     if sectorComlete 
%         if AllSectorsCovered
%             %Go Home
%         else
%             %Pick Closest Non-Active Square
%             %Generate Target List and Reset Index 
%         end
%     else
%         %Collect Data
%         %Calculate Displacement
%     end
% end











