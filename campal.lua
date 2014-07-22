local moduleSettings = {
	["Admins"] = {"Niunzin"},
	["Game Masters"] = {""},
	["Mapcrews"] = {""},
	["RoundTime"] = 600,
	["Maplist"] = {},
	["Ban List"] = {},
	["Languages"] = {
		["br"] = {
					["message_newGame"] = "Nova rodada!",
					["message_newGame_rush"] = "Modo atual: <b>Rush</b>",
				},
	}
}

local currentGame = {
	["Teams"] = {
		["Alpha"] = {
				["leader"] = "undefined",
				["members"] = {},
				["win"] = false,
				["points"] = 0,
			},
		["Omega"] = {
				["leader"] = "undefined",
				["members"] = {},
				["win"] = false,
				["points"] = 0,
		}
	},
	["Mode"] = "Rush",
	["Lastmode"] = nil
}

local campalUtils = {}
local campalExec = tfm.exec
local campalGet = tfm.get
local campalUI = ui
local campalMessageShow = 0
local campalMessageQueue = {}
local campalInit = tfm.exec.newGame(0)
local tr = moduleSettings["Languages"]["br"]

function campalUtils.showMessage(Message, Target, Duration)
	local Duration = (Duration * 2) or 10
	if(campalMessageShow == 0) then
		-- Shadow
		campalUI.addTextArea(875, string.format("<p align=\"center\"><font size=\"31\" color=\"#000000\">%s</font></p>", Message), Target, 0, 30, 800, 48, nil, nil, 0, true)
		-- Text
		campalUI.addTextArea(876, string.format("<p align=\"center\"><font size=\"30\" color=\"#ff8000\">%s</font></p>", Message), Target, 0, 30, 800, 48, nil, nil, 0, true)
		
		campalMessageShow = Duration
	else
		local data = { ["message"] = Message, ["target"] = Target, ["duration"] = Duration }
		table.insert(campalMessageQueue, data)
	end
end

function eventLoop(currentTime, timeRemaining)
	campalMessageShow = campalMessageShow - 1
	if(campalMessageShow == 0) then
		campalUI.removeTextArea(875, nil)
		campalUI.removeTextArea(876, nil)
		if(campalMessageQueue[1] ~= nil) then
			local nextMessage = campalMessageQueue[1]
			campalUtils.showMessage(nextMessage["message"], nextMessage["target"], nextMessage["duration"])
			campalMessageShow = nextMessage["duration"]
			table.remove(campalMessageQueue, 1)
		end
	end
end

function eventNewGame()
	if(currentGame["Lastmode"] == nil) then
		currentGame["Mode"] = "Rush"
	end
	
	if(currentGame["Mode"] == "Rush") then
		campalUtils.showMessage(tr["message_newGame"], nil, 5)
		campalUtils.showMessage(tr["message_newGame_rush"], nil, 5)
	end
end
