local moduleSettings = {
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
				["message_newGame_4"] = "Sua equipe: <font color=\"#F0A78E\">%s</font>. Boa sorte.",
				["message_error"] = "<R>Falha ao iniciar partida, pontos não identificados no mapa <B>%s</B>.",
			},
	}
}

local currentGame = {
	["Teams"] = {
		{
			["name"] = "Alpha",
			["leader"] = "undefined",
			["members"] = { ["c"] = true },
			["win"] = false,
			["points"] = 0,
			["color"] = 0x08CFFF,
			["location"] = { ["x"] = 0, ["y"] = 0 },
		},
		{
			["name"] = "Omega",
			["leader"] = "undefined",
			["members"] = { ["c"] = true },
			["win"] = false,
			["points"] = 0,
			["color"] = 0xEB1D51,
			["location"] = { ["x"] = 0, ["y"] = 0 },
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
local campalCurrentMap = {}
local tr = moduleSettings["Languages"]["br"]
local campalTime = 0
local campalStarted = false

campalExec.disableAutoShaman(true)
campalExec.disableAutoNewGame(true)
campalExec.disableAutoScore(true)
campalExec.disableAutoTimeLeft(true)
campalExec.disableAfkDeath(true)

string.lpad = function(str, len, char)
	if char == nil then char = ' ' end
	return str .. string.rep(char, len - #str)
end

function campalUtils.split(string)
	t={}
	for w in string:gmatch("%S+") do
		table.insert(t,w)
	end
	return t
end

function campalUtils.showMessage(Message, Duration)
	local duration = (Duration * 2) or 10
	if(campalMessageShow == 0) then
		campalUI.addTextArea(876, string.format("<p align=\"center\"><font size=\"30\" color=\"#E68D43\">%s</font></p>", Message), nil, 0, 30, 800, 48, nil, nil, 0, true)
		campalMessageShow = duration
	else
		local data = { ["message"] = Message, ["target"] = Target, ["duration"] = duration }
		table.insert(campalMessageQueue, data)
	end
end

function campalUtils.getPlayerTeamName(player)
	for index, value in pairs(currentGame["Teams"]) do
		for i, v in pairs(value["members"]) do
			if(v) then
				return value["name"]
			end
		end
	end
end

function campalUtils.getPlayerTeam(player)
	for index, value in pairs(currentGame["Teams"]) do
		for i, v in pairs(value["members"]) do
			if(v) then
				return index
			end
		end
	end
end

local i = 0
function campalUtils.buildTeams()
	for player in pairs(campalGet.room.playerList) do
		i = i+1
		if i%2==0 then
			currentGame["Teams"][2]["members"][player] = true
			campalExec.setNameColor(player, currentGame["Teams"][2]["color"])
			campalExec.chatMessage(string.format("<V>%s entrou para %s.", player, currentGame["Teams"][2]["name"]))
		else
			currentGame["Teams"][1]["members"][player] = true
			campalExec.setNameColor(player, currentGame["Teams"][1]["color"])
			campalExec.chatMessage(string.format("<V>%s entrou para %s.", player, currentGame["Teams"][1]["name"]))
		end
	end
end


local isec = 0
function eventLoop(currentTime, timeRemaining)
	isec = isec + 1
	if(isec % 2 == 0) then
		campalTime = campalTime + 1
	end
	
	moduleSettings["RoundTime"] = moduleSettings["RoundTime"] - 1;
	minutes = moduleSettings["RoundTime"] / 60;
	sec = moduleSettings["RoundTime"] % 60;
	str_sec = sec
	
	if(string.len(str_sec) == 1) then
		str_sec = "0" .. str_sec
	end
	
	tfm.exec.setUIMapName("0" .. string.sub(minutes, 0, 1) .. ":" .. str_sec .. "<")
	
	if(campalTime == 11) then
		for player in pairs(campalGet.room.playerList) do
			if(campalUtils.getPlayerTeamName(player) == currentGame["Teams"][1]["name"]) then
				campalExec.movePlayer(player, currentGame["Teams"][1]["location"]["x"], currentGame["Teams"][1]["location"]["y"])
			elseif(campalUtils.getPlayerTeamName(player) == currentGame["Teams"][2]["name"]) then
				campalExec.movePlayer(player, currentGame["Teams"][2]["location"]["x"], currentGame["Teams"][2]["location"]["y"])
			end
		end
		campalStarted = true
	end
	
	campalMessageShow = campalMessageShow - 1
	if(campalMessageShow == 0) then
		campalUI.removeTextArea(876, nil)
		if(campalMessageQueue[1] ~= nil) then
			local nextMessage = campalMessageQueue[1]
			campalUtils.showMessage(nextMessage["message"], nextMessage["duration"])
			campalMessageShow = nextMessage["duration"]
			table.remove(campalMessageQueue, 1)
		end
	end
end

function eventNewGame()
	if(string.match(campalGet.room.xmlMapInfo.xml, "<O>")) then
		local plainXml = tfm.get.room.xmlMapInfo.xml;
		local pfindO = string.find(plainXml, "<O>");
		local finded = string.sub(plainXml, pfindO)
		local pfinded = string.sub(plainXml, pfindO);
		local pfindEndO = string.find(string.sub(plainXml, pfindO), "</O>");
		local pindex = pfindEndO - pfindO;
		local ready = string.sub(finded, 4, pindex);
		local replaced = ready:gsub("<", "&lt;");
		local redY = string.match(replaced, " C=\"11\" Y=\"%d+\""):gsub(" C=\"11\" Y=\"", ""):gsub("\"", "");
		local redX = string.match(replaced, "X=\"%d+\""):gsub("X=\"", ""):gsub("\"", "");
		local strBlueStart = replaced:gsub("X=\"" .. redX .. "\"", ""):gsub(" C=\"14\" Y=\"" .. redY .. "\"", "")
		local blueY = string.match(strBlueStart, "Y=\"%d+\""):gsub("Y=\"", ""):gsub("\"", "");
		local blueX = string.match(strBlueStart, "X=\"%d+\""):gsub("X=\"", ""):gsub("\"", "");
		if(blueY == nil) then
			blueY = redY;
		end
		currentGame["Teams"][1]["location"]["x"] = redX;
		currentGame["Teams"][1]["location"]["y"] = redY;
		currentGame["Teams"][2]["location"]["x"] = blueX;
		currentGame["Teams"][2]["location"]["y"] = blueY;
	else
		campalExec.chatMessage(string.format(tr["message_error"], campalCurrentMap["name"]))
	end
end

function campalInit()
	campalUtils.buildTeams()
	
	if(currentGame["Lastmode"] == nil) then
		currentGame["Mode"] = "Rush"
	end
	
	if(currentGame["Mode"] == "Rush") then
		local mapList = moduleSettings["Maplist"]["Rush"]
		campalCurrentMap = mapList[math.random(#mapList)]
		local mapName = campalCurrentMap["name"]
		local mapCode = campalCurrentMap["code"]
		local mapAuthor = campalCurrentMap["author"]
		campalExec.newGame(mapCode)
		campalUtils.showMessage(tr["message_newGame"], 2)
		campalUtils.showMessage(string.format(tr["message_newGame_2"], currentGame["Mode"]), 3)
		campalUtils.showMessage(string.format(tr["message_newGame_3"], mapName, mapAuthor), 2)
	end
end

campalInit()
