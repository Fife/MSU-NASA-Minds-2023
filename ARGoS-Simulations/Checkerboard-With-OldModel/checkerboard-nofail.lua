require ('CooperativeMapping')

-- Use Shift + Click to select a robot
-- Put your global variables here

Home_coord = {-1.6, -1.6}
NumberOfBots = 3
FieldSize = 30
Center = {0,0}
AgentMap = {}
AgentState= {}

--[[ This function is executed every time you press the 'execute' button ]]
function init()
	AgentMap = CoopMappingAlgorithmInit(Home_coord, NumberOfBots, FieldSize, Center)

end


--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	--Communication Logic

	--Transmit square to everybody in range
	--robot.radios.radio_tx.tx_data({mySquare})
--[[
	--Receive everybody elses data
	--If there is data to receive
	if # robot.radios.radio_rx.rx_data > 0 then
		--Update the map
		for i = 1, #robot.radios.radio_rx.rx_data, 1 do
			fieldStatus[robot.radios.radio_rx.rx_data[i][1]] --= --true
		--end
	--end ]]


	CoopMappingAlgorithmStep(AgentMap, AgentState)
	log(AgentMap["target"]["x"])
	log(AgentMap["target"]["y"])
	log(robot.positioning.position.x)
	log(robot.positioning.position.y)

end

function reset()
	init()
end

function destroy()

end
