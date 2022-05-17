-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local currentZone = nil
local PlayerData = {}
local Targets = {}

-- Handlers
AddEventHandler('onResourceStart', function(r) if (GetCurrentResourceName() ~= r) then return end PlayerData = QBCore.Functions.GetPlayerData() end)
AddEventHandler('QBCore:Client:OnPlayerLoaded', function() PlayerData = QBCore.Functions.GetPlayerData() end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerData.job = JobInfo end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() PlayerData = {} end)

CreateThread(function()
	for i = 1, #Config.Locations do
		if Config.Locations[i].enableBooth then
			Targets["Booth"..i] =
			exports['qb-target']:AddCircleZone("Booth"..i, Config.Locations[i].coords, 0.6, {name="Booth"..i, debugPoly=Config.Debug, useZ=true, },
				{ options = { { event = "qb-djbooth:client:playMusic", icon = "fab fa-youtube", label = "DJ Booth", job = Config.Locations[i].job, zone = i, }, }, distance = 2.0 })
		end
	end
end)

RegisterNetEvent("qb-djbooth:client:playMusic", function(data)
	exports["qb-menu"]:openMenu({ 
		{ isMenuHeader = true, header = '<img src=https://cdn-icons-png.flaticon.com/512/1384/1384060.png width=20px></img>&nbsp; DJ Booth' },
		{ icon = "fas fa-circle-xmark", header = "", txt = "Close", params = { event = "qb-menu:client:closemenu" } },
		{ icon = "fab fa-youtube", header = "Play a song", txt = "Enter a youtube URL", params = { event = "qb-djbooth:client:musicMenu", args = { zoneNum = data.zone } } },
		{ icon = "fas fa-pause", header = "Pause Music", txt = "Pause music", params = { isServer = true, event = "qb-djbooth:server:pauseMusic", args = { zoneNum = data.zone } } },
		{ icon = "fas fa-play", header = "Resume Music", txt = "Resume music", params = { isServer = true, event = "qb-djbooth:server:resumeMusic", args = { zoneNum = data.zone } } },
		{ icon = "fas fa-volume-off", header = "Volume", txt = "Change volume", params = { event = "qb-djbooth:client:changeVolume", args = { zoneNum = data.zone,  } } },
		{ icon = "fas fa-stop", header = "Stop music", txt = "Turn off the music", params = { isServer = true, event = "qb-djbooth:server:stopMusic", args = { zoneNum = data.zone } } } })
end)

RegisterNetEvent('qb-djbooth:client:musicMenu', function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = 'Song Selection',
        submitText = "Submit",
        inputs = { { type = 'text', isRequired = true, name = 'song', text = 'YouTube URL' } } })
    if dialog then
        if not dialog.song then return end
		-- Attempt to correct link if missing "youtube" as some scripts use just the video id at the end
		if not string.find(dialog.song, "youtu") then dialog.song = "https://www.youtube.com/watch?v="..dialog.song end
		TriggerEvent("QBCore:Notify", "Loading link: "..dialog.song)
        TriggerServerEvent('qb-djbooth:server:playMusic', dialog.song, data.zoneNum)
    end
end)

RegisterNetEvent('qb-djbooth:client:changeVolume', function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = 'Music Volume',
        submitText = "Submit",
        inputs = { { type = 'text', isRequired = true,  name = 'volume', text = "Min: 0 - Max: 100" } } })
    if dialog then
        if not dialog.volume then return end
		-- Automatically correct from numbers to be numbers xsound understands
		dialog.volume = (dialog.volume / 100)
		-- Don't let numbers go too high or too low
		if dialog.volume <= 0.01 then dialog.volume = 0.01 end
		if dialog.volume > 1.0 then dialog.volume = 1.0 end
		TriggerEvent("QBCore:Notify", "Setting booth audio to: "..math.ceil(dialog.volume * 100).."%", "success")
        TriggerServerEvent('qb-djbooth:server:changeVolume', dialog.volume, data.zoneNum)
    end
end)


AddEventHandler('onResourceStop', function(r) 
	if r ~= GetCurrentResourceName() then return end
	for k, v in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
end)