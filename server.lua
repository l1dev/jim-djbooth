local QBCore = exports[Config.Core]:GetCoreObject()

previousSongs, CurrentBooths = {}, {}
local function DestroyAll()
	for i = 1, #Config.Locations do
		local Booth = Config.Locations[i]
		if Booth.playing then local zoneLabel = ""..(Booth.gang or Booth.job)..i exports["xsound"]:Destroy(-1, zoneLabel) end
	end
end

RegisterNetEvent('jim-djbooth:server:AddLocation', function(data)
	DestroyAll()
	Config.Locations[#Config.Locations+1] = data
	TriggerClientEvent("jim-djbooth:client:syncLocations", -1, Config.Locations)
end)

RegisterNetEvent('jim-djbooth:server:playMusic', function(song, zoneNum)
    local src, coords, Booth = source, GetEntityCoords(ped), Config.Locations[zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..zoneNum
	if not previousSongs[zoneLabel] then previousSongs[zoneLabel] = { [1] = song, }
	elseif previousSongs[zoneLabel] then
		local songList = previousSongs[zoneLabel]
		songList[#songList+1] = song
		previousSongs[zoneLabel] = songList
	end
	exports["xsound"]:PlayUrlPos(-1, zoneLabel, song, (Booth.CurrentVolume or Booth.DefaultVolume), (Booth.soundLoc or Booth.coords))
	exports["xsound"]:Distance(-1, zoneLabel, Booth.radius)
	Config.Locations[zoneNum].playing = true
	TriggerClientEvent('jim-djbooth:client:playMusic', src, { zoneNum = zoneNum })
end)

RegisterNetEvent('jim-djbooth:server:stopMusic', function(data)
    local src, Booth = source, Config.Locations[data.zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..data.zoneNum
    if Booth.playing then Config.Locations[data.zoneNum].playing = nil Config.Locations[data.zoneNum].CurrentVolume = nil exports["xsound"]:Destroy(-1, zoneLabel) end
    TriggerClientEvent('jim-djbooth:client:playMusic', src, { zoneNum = data.zoneNum })
end)

RegisterNetEvent("jim-djbooth:server:PauseResume", function(data)
    local src, Booth = source, Config.Locations[data.zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..data.zoneNum
	if Booth.playing then Booth.playing = nil exports["xsound"]:Pause(-1, zoneLabel)
	elseif not Config.Locations[data.zoneNum].playing then Config.Locations[data.zoneNum].playing = true exports["xsound"]:Resume(-1, zoneLabel) end
    TriggerClientEvent('jim-djbooth:client:playMusic', src, { zoneNum = data.zoneNum })
end)

RegisterNetEvent('jim-djbooth:server:changeVolume', function(volume, zoneNum)
    local src, Booth = source, Config.Locations[zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..zoneNum
    if not tonumber(volume) then return end
    if Booth.playing then exports["xsound"]:setVolume(-1, zoneLabel, volume) Config.Locations[zoneNum].CurrentVolume = volume end
    TriggerClientEvent('jim-djbooth:client:playMusic', src, { zoneNum = zoneNum })
end)

QBCore.Functions.CreateCallback('jim-djbooth:songInfo', function(source, cb) cb(previousSongs) end)

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() then return end DestroyAll() end)

local function CheckVersion()
	PerformHttpRequest('https://raw.githubusercontent.com/jimathy/jim-djbooth/master/version.txt', function(err, newestVersion, headers)
		local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
		if not newestVersion then print("Currently unable to run a version check.") return end
		local advice = "^1You are currently running an outdated version^7, ^1please update^7"
		if newestVersion:gsub("%s+", "") == currentVersion:gsub("%s+", "") then advice = '^6You are running the latest version.^7'
		else print("^3Version Check^7: ^2Current^7: '^5"..currentVersion.."^7' ^2Latest^7: '^5"..newestVersion.."^7'") end
		print(advice)
	end)
end
CheckVersion()