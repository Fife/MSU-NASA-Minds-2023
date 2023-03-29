require('movement-functions')
require('mapping-functions')

Map = {
    --Map Meta Data
    home_coordinate = {},
	field = {},
	fieldStatus = {},

    --Chunk Data
    chunkLength = 0,

    --Target List (Changes every chunk)
    targetList = {},
    targetIndex = 1,
    currentSquare = {},
    squareIndex = {},
    --Current Target (Can be changed by obstacleAvoid and setTarget)
    target = {},

    --Scientific Data
    Data = {},
    displacement_thresh = 0,
    last_data_point = {x=0, y=0},

    --GPR Sweep Info
    gprWidth = 0.25,
}

AgentState = {
    agents = {}
}


function CoopMappingAlgorithmInit(home_coord, numberOfBots, size, center)
    local map = Map
    local idNumber = string.gsub(robot.id, "gpr", "")
    idNumber = string.gsub(idNumber, "-bot", "") + 1

    --Set Home Coordinate and Chunk out the entire field
    map["home_coordinate"] = home_coord
    map["field"] = Chunk(size, size, numberOfBots, center)

    --Set the Field Statuses
    for i = 1,#map["field"], 1 do 
        table.insert(map["fieldStatus"], false)
    end
    map["chunkLength"] = size/numberOfBots

    --Pick First Chunk
    map["currentSquare"] = map["field"][idNumber]

    --Generate Target List and Set Index
    map["targetIndex"] = 1
    map["targetList"] = GeneratePath(map["currentSquare"]["bl"], map["chunkLength"], map["gprWidth"] , 0)

    --Set Target to starting coordinate of chunk
    map["target"] = map["currentSquare"]["bl"]
    return map
end

function CoopMappingAlgorithmStep(map, agentState)
    local speed = 5

	if (SectorComplete(map)) then
		if(AllSectorsCovered(map)) then
			map["target"] = map["home_coordinate"]
		else
            --Pick closest, non active square
			map["currentSquare"] = ClosestSquare(map)
			map["target"] = map["currentSquare"]["bl"]

            --Generate Target List and Reset Index
            map["targetIndex"] = 1
            map["targetList"] = GeneratePath(map["currentSquare"]["bl"], map["chunkLength"], map["gprWidth"] , 0)
	    end

	else
        CollectData(map)
        if (ArrivedAtTarget(map)) then
            map["target"]  = NextTarget(map)
        elseif (ArrivedAtTarget(map) and map["target"]["x"] == map["home_coordinate"]["x"] and map["target"]["y"] == map["home_coordinate"]["y"]) then
            --We have arrived at the home target, which means we are done. Kill the speed 
            speed = 0
        end
    end

    --If we detect an obstacle, we will temporarily change the current target to avoid it
--[[
 if ObstacleDetect() then
        map["target"] = ObstacleAvoid();
    end

]]  

    --Drive toward the target
    DriveTo(map["target"]["x"], map["target"]["y"], speed)

	BroadcastUpdate(agentState)
	ReceiveUpdate(agentState)

end


function NextTarget(map)
    --We have more targets in our list, so increment the target index
    map["targetIndex"] = map["targetIndex"] + 1
    local index = map["targetIndex"]
    log("Picking next target")
    --Set the current target to the next target in the list
    return {x = map["targetList"][index][1], y = map["targetList"][index][2]}
end

function CollectData(map)
    --Calculate Displacement 
    local x_disp = robot.positioning.position.x - map["last_data_point"]["x"]
    local y_disp = robot.positioning.position.y - map["last_data_point"]["y"]
    local displacement = math.sqrt(x_disp*x_disp + y_disp*y_disp)

    --If we've traveled far enough, take a data reading
    table.insert(map["Data"], {robot.positioning.position.x, robot.positioning.position.y})
    if map["displacement_thresh"] >= displacement then
        table.insert(map["Data"], {robot.positioning.position.x, robot.positioning.position.y})
    end
end

function ArrivedAtTarget(map)
	local current_x= robot.positioning.position.x
	local current_y= robot.positioning.position.y

	--Create Trajectory vector pointing at the next target 
	local sum_of_squares = ((map["target"]["x"] - current_x)^2) + ((map["target"]["y"] - current_y)^2)
	local traj_magnitude = math.sqrt(sum_of_squares)
    log(traj_magnitude)
    if (traj_magnitude < 0.1) then
		return true
    end
	return false
end

function AllSectorsCovered(map)
    for i = 1, #map["fieldStatus"], 1 do
        if map["fieldStatus"][i] == false then
            return false
        end
    end
    return true
end

function SectorComplete(map)
    if map["targetIndex"] == #map["targetList"] then
        map["fieldStatus"][map["squareIndex"]] = true
        return true
    else
        return false
    end
end

function ClosestSquare(map)
    local distanceList = {}
    local x = robot.positioning.position.x
    local y = robot.positioning.position.y

    for k = 1, #map["fieldStatus"], 1 do
        if map["fieldStatus"][k] == false then
            local xfieldval = map["field"][k]["bl"]["x"]
            local yfieldval = map["field"][k]["bl"]["y"]
            local distance = math.sqrt((xfieldval-x)^2 + (yfieldval-y)^2)
            table.insert(distanceList, {key=k, val=distance})
        end
    end
    
    local square = {}
    local minimum = math.huge

    for i=1, #distanceList, 1 do
        if distanceList[i]["val"] < minimum then
            square = distanceList[i]["key"]
            minimum = distanceList[i]["val"]
        end
    end
    map["squareIndex"] = square
    return map["field"][square]
end

function AgentInSector(map)
    --Variables so that the bounding check isnt crazy long
    local x = robot.positioning.position.x
    local y = robot.positioning.position.y

    --Quick bounding box stuff
    if x > map["currentSquare"]["bl"]["x"] and x < map["currentSquare"]["br"]["x"] and y > map["currentSquare"]["bl"]["y"] and y < map["currentSquare"]["tl"]["y"] then
        return true
    else 
        return false
    end
end

function GeneratePath(bottom_left, length, width, offset)
	local travel_path = {}
	local start = {bottom_left["x"]+offset, bottom_left["y"]+offset}
	local x = start[1]
	local y = start[2]
	table.insert(travel_path, start)
	for i = 1,(length/(2*width)), 1 
		do 
			x = x + length
			table.insert(travel_path,{x, y})
			y = y + width
			table.insert(travel_path,{x, y})
			x = x - length
			table.insert(travel_path,{x, y})
			y = y + width
			table.insert(travel_path,{x, y})
	end
	x = x + length
	table.insert(travel_path,{x, y})
	for i = 1,(length/(2*width)), 1 
		do 
			y = y - length
			table.insert(travel_path,{x, y})
			x = x - width
			table.insert(travel_path,{x, y})
			y = y + length
			table.insert(travel_path,{x, y})
			x = x - width
			table.insert(travel_path,{x, y})
	end
	y = y - length
	table.insert(travel_path,{x, y})
	return travel_path
end

function Chunk(xLength, yLength, numSqr, center)
    local squareList = {}
    local square ={}
    offset =  {x=center[1]-(0.5*xLength) , y=center[2]-(0.5*yLength)}
     for j = 0,numSqr-1,1
       do
        columns = {}
       for i = 0,numSqr-1,1
           do
           tl={x=(xLength/numSqr)*i+offset["x"], y=(yLength/numSqr)*(j+1)+offset["y"]}
           bl={x=((xLength/numSqr)*i)+offset["x"], y=(yLength/numSqr)*j+offset["y"]}
           tr={x=(xLength/numSqr)*(i+1)+offset["x"], y=(yLength/numSqr)*(j+1)+offset["y"]}
           br={x=(xLength/numSqr)*(i+1)+offset["x"], y=(yLength/numSqr)*j+offset["y"]}
           table.insert(squareList, {tl=tl, bl=bl, tr=tr, br=br})
       end
   end
   return squareList
end


function BroadcastUpdate(agentState)
    log(agentState)
end

function ReceiveUpdate(agentState)
    log(agentState)
end
