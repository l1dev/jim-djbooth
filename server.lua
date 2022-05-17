local xSound = exports.xsound

RegisterNetEvent('qb-djbooth:server:playMusic', function(song, zoneNum)
    local src = source
	local Booth = Config.Locations[zoneNum]
	local zoneLabel = Config.Locations[zoneNum].label..zoneNum
    xSound:PlayUrlPos(-1, zoneLabel, song, Config.DefaultVolume, GetEntityCoords(GetPlayerPed(src)))
    xSound:Distance(-1, zoneLabel, Booth.radius)
    Config.Locations[zoneNum].playing = true
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = zoneNum })
end)

RegisterNetEvent('qb-djbooth:server:stopMusic', function(data)
    local src = source
	local zoneLabel = Config.Locations[data.zoneNum].label..data.zoneName
    if Config.Locations[data.zoneNum].playing then
        Config.Locations[data.zoneNum].playing = false
        xSound:Destroy(-1, zoneLabel)
    end
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = data.zoneNum })
end)

RegisterNetEvent('qb-djbooth:server:pauseMusic', function(data)
    local src = source
    if Config.Locations[data.zoneNum].playing then
        Config.Locations[data.zoneNum].playing = false
        xSound:Pause(-1, zoneLabel)
    end
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = data.zoneNum })
end)

RegisterNetEvent('qb-djbooth:server:resumeMusic', function(data)
    local src = source
    if not Config.Locations[data.zoneNum].playing then
        Config.Locations[data.zoneNum].playing = true
        xSound:Resume(-1, zoneLabel)
    end
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = data.zoneNum })
end)

RegisterNetEvent('qb-djbooth:server:changeVolume', function(volume, zoneNum)
    local src = source
	local Booth = Config.Locations[zoneNum]
	local zoneLabel = Config.Locations[zoneNum].label..zoneNum
    if not tonumber(volume) then return end
    if Config.Locations[zoneNum].playing then
        xSound:setVolume(-1, zoneLabel, volume)
    end
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = zoneNum })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
	for i = 1, #Config.Locations do
		if Config.Locations[i].playing then
			local zoneLabel = Config.Locations[i].label..i
			xSound:Destroy(-1, zoneLabel)
		end
	end
end)
