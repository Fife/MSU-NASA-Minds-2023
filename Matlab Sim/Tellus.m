classdef Tellus
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % 1 Is occupied, 2 is complete
        fieldStatus = []

        fieldIndex = 1
        startingPoints= []

        current_coord = []
        path = []
        
        scanRate = 1/20;
        velocity = 1;
        pathIndex = 1
        data = [];
        granularity = 4;
        chunkLen
        offset = 0;
        radius= 0.1;
        
        combingPos = 0;
        numBots = 0;
    end

    methods
        function [obj, fieldStatus] = init(obj, startPoints, chunkLen, start_coord, startChunk, radius, fieldStatus)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here

            %Initialize the field
            obj.fieldStatus = fieldStatus;
            obj.fieldIndex = 1;
            obj.current_coord = start_coord; 
            obj.chunkLen = chunkLen;
            obj.startingPoints = startPoints; 
            obj.radius = radius;
            obj.offset = 0;
            %Pick a chunk
            obj.fieldIndex = startChunk; 
            obj.fieldStatus(obj.fieldIndex) = true; 
            %Insert Starting Point into path 
            %Append Path with Generate Path call 
            obj.path = [obj.path, GeneratePath(startPoints(obj.fieldIndex), chunkLen-(obj.radius), (chunkLen-(obj.radius))/obj.granularity, obj.offset)];
            
            fieldStatus = obj.fieldStatus; 
        end

        function [obj, fieldStatus] = step(obj, fieldStatus)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.fieldStatus = fieldStatus;
            % If the sector is complete
            if obj.pathIndex > length(obj.path)
                %If we have completed all sectors
                if sum(obj.fieldStatus) == length(obj.fieldStatus)*2
                    %Go Home
                    obj.path = [obj.startingPoints{1}(1), obj.startingPoints{1}(2)];
                    obj.pathIndex = 1;

                elseif ~ismember(obj.fieldStatus, 0)
                    obj.path = [obj.startingPoints{1}(1), obj.startingPoints{1}(2)];
                    obj.pathIndex = 1;
                    obj.fieldStatus(obj.fieldIndex) = 2; 
                else
                    %Mark Field Status as complete
                    obj.fieldStatus(obj.fieldIndex) = 2; 

                    %Pick Closest Non Active Square
                    distances = [];
                    for i =1:length(obj.fieldStatus)
                        dist = inf;
                        if (obj.fieldStatus(i) == 0)
                            dist = norm(obj.current_coord - obj.startingPoints{i});
                        end
                        distances = [distances, dist];
                    end
                    [Min, MinIndex] = min(distances);
                    if Min ~= inf
                        %Set Index to closest non acive square, mark new square
                        %as active
                        obj.fieldIndex = MinIndex;
                        obj.fieldStatus(obj.fieldIndex) = 1; 
                    end


                    %Generate Path and Reset Index
                    obj.path = [GeneratePath(obj.startingPoints(obj.fieldIndex), obj.chunkLen-(obj.radius)-obj.offset, (obj.chunkLen-(obj.radius))/obj.granularity, obj.offset)];
                    obj.pathIndex = 1;
                end
            end
            %Sector is not complete, calculate next movement Step
            
            distance_to_target = sqrt((obj.path(obj.pathIndex)-obj.current_coord(1))^2  + (obj.path(obj.pathIndex+1)-obj.current_coord(2))^2); 
           
            %If we're really close, set the next target
            if distance_to_target < 0.05
                obj.pathIndex = obj.pathIndex + 2;
            %Calculate the trajectory and multiply the vector by the step length
            else
                traj = [obj.path(obj.pathIndex) - obj.current_coord(1),  obj.path(obj.pathIndex+1) - obj.current_coord(2)];
                utraj = traj/(norm(traj));
        
                distance_step = obj.scanRate*obj.velocity*utraj;
                obj.current_coord = obj.current_coord + distance_step;
        
                obj.data = [obj.data, {obj.current_coord}];
            end         
            fieldStatus = obj.fieldStatus;
        end

        function [obj, fieldStatus] = combInit(obj, fieldStatus, spawnCoord, startCoord, chunkLength, radius, numBots, combingPos)
            %Initialize the combing pattern 
            obj.fieldStatus = fieldStatus;
            obj.fieldIndex = 1;
            obj.current_coord = spawnCoord; 
            obj.chunkLen = chunkLength;
            obj.radius = radius;
            obj.numBots = numBots;
            obj.combingPos = combingPos;

            %Append Path with Generate Path call 
            centerPath = GeneratePath({startCoord}, chunkLength-(obj.numBots*obj.radius), (obj.chunkLen-(2*obj.radius))/obj.granularity, numBots*radius);
            if combingPos == 1
                obj.path = centerPath;
            else
                obj.path = generateCombPath(centerPath, combingPos, radius);
            end
        end

        function [obj, fieldStatus] = combStep(obj, fieldStatus)
             % If the sector is complete
            if obj.pathIndex > length(obj.path)
                obj.path = [obj.path(1), obj.path(2)];
                obj.pathIndex = 1;
                obj.fieldStatus = [obj.fieldStatus 2];
            else
                distance_to_target = sqrt((obj.path(obj.pathIndex)-obj.current_coord(1))^2  + (obj.path(obj.pathIndex+1)-obj.current_coord(2))^2);
                %If we're really close, set the next target
                if distance_to_target < 0.02
                    obj.pathIndex = obj.pathIndex + 2;
                %Calculate the trajectory and multiply the vector by the step length
                else
                    traj = [obj.path(obj.pathIndex) - obj.current_coord(1),  obj.path(obj.pathIndex+1) - obj.current_coord(2)];
                    utraj = traj/(norm(traj));
            
                    distance_step = obj.scanRate*obj.velocity*utraj;
                    obj.current_coord = obj.current_coord + distance_step;
            
                    obj.data = [obj.data, {obj.current_coord}];
                end         

             end
            fieldStatus = obj.fieldStatus;
         end

    end
end