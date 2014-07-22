moduleSettings = {
	["Admins"] = {"Niunzin"},
	["Game Masters"] = {""},
	["Mapcrews"] = {""},
	["RoundTime"] = 600,
	["Maplist"] = {
		["Rush"] = {
			{ ["code"] = "@5263734", ["author"] = "Niunzin", ["name"] = "Tropical Islands" },
		},
		["Capture the Flag"] = {
		},
		["Team deathmatch"] = {
		},
	},
	["Ban List"] = {},
	["Languages"] = {
		["br"] = {
					["message_newGame"] = "Nova rodada!",
					["message_newGame_2"] = "Modo de jogo: <font color=\"#F0A78E\">%s</font>",
					["message_newGame_3"] = "Mapa <font color=\"#F0A78E\">%s</font>, por <font color=\"#F0A78E\">%s</font>.",
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
	["Lastmode"] = nil,
	["Map"] = nil,
}

local campalUtils = {}
local campalExec = tfm.exec
local campalGet = tfm.get
local campalUI = ui
local campalMessageShow = 0
local campalMessageQueue = {}
local tr = moduleSettings["Languages"]["br"]

campalExec.disableAutoShaman(true)
campalExec.disableAutoNewGame(true)
campalExec.disableAutoScore(true)
campalExec.disableAutoTimeLeft(true)
campalExec.disableAfkDeath(true)

function campalUtils.showMessage(Message, Target, Duration)
	local Duration = (Duration * 2) or 10
	if(campalMessageShow == 0) then
		campalUI.addTextArea(876, string.format("<p align=\"center\"><font size=\"30\" color=\"#E68D43\">%s</font></p>", Message), Target, 0, 30, 800, 48, nil, nil, 0, true)
		campalMessageShow = Duration
	else
		local data = { ["message"] = Message, ["target"] = Target, ["duration"] = Duration }
		table.insert(campalMessageQueue, data)
	end
end

function eventLoop(currentTime, timeRemaining)
	campalMessageShow = campalMessageShow - 1
	if(campalMessageShow == 0) then
		campalUI.removeTextArea(876, nil)
		if(campalMessageQueue[1] ~= nil) then
			local nextMessage = campalMessageQueue[1]
			campalUtils.showMessage(nextMessage["message"], nextMessage["target"], nextMessage["duration"])
			campalMessageShow = nextMessage["duration"]
			table.remove(campalMessageQueue, 1)
		end
	end
end

function campalInit()
	if(currentGame["Lastmode"] == nil) then
		currentGame["Mode"] = "Rush"
	end
	
	if(currentGame["Mode"] == "Rush") then
		local mapList = moduleSettings["Maplist"]["Rush"]
		local currentMap = mapList[math.random(#mapList)]
		local mapName = currentMap["name"]
		local mapCode = currentMap["code"]
		local mapAuthor = currentMap["author"]
		campalExec.newGame(mapCode)
		campalUtils.showMessage(tr["message_newGame"], nil, 3)
		campalUtils.showMessage(string.format(tr["message_newGame_2"], currentGame["Mode"]), nil, 3)
		campalUtils.showMessage(string.format(tr["message_newGame_3"], mapName, mapAuthor), nil, 5)
	end
end

campalInit()
