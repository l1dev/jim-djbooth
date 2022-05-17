local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local Targets = {}

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
	local song = { icon = "", header = "", txt = "🔇 No Song Playing", volume = "" }
	local p = promise.new()	local p2 = promise.new()
	QBCore.Functions.TriggerCallback('qb-djbooth:currentSong', function(cb, cb2) p:resolve(cb) p2:resolve(cb2) end)
	currentSong = Citizen.Await(p) previousSongs = Citizen.Await(p2)
	if currentSong[(PlayerData.job.name..data.zone)] then
		local currentSong = currentSong[(PlayerData.job.name..data.zone)]
		song = {
				--Attempt to grab thumbnail to put in icon
				icon = "https://img.youtube.com/vi/"..string.sub(currentSong.url, - 11).."/mqdefault.jpg",
				header = "Currently "..currentSong.status,
				txt = currentSong.url,
				volume = ": "..math.ceil(currentSong.volume*100).."%"
		}
	end
	local musicMenu = {}
	musicMenu[#musicMenu+1] = { isMenuHeader = true, header = '<img src=https://cdn-icons-png.flaticon.com/512/1384/1384060.png width=20px></img>&nbsp; DJ Booth' }
	musicMenu[#musicMenu+1] = { isMenuHeader = true, icon = song.icon, header = song.header, txt = song.txt }
	musicMenu[#musicMenu+1] = { icon = "fas fa-circle-xmark", header = "", txt = "Close", params = { event = "qb-menu:client:closemenu" } }
	musicMenu[#musicMenu+1] = { icon = "fab fa-youtube", header = "Play a song", txt = "Enter a youtube URL", params = { event = "qb-djbooth:client:musicMenu", args = { zoneNum = data.zone } } }
	if previousSongs[(PlayerData.job.name..data.zone)] then 
		musicMenu[#musicMenu+1] = { icon = "fas fa-clock-rotate-left", header = "Song History", txt = "View previous songs", params = { event = "qb-djbooth:client:history", args = { history = previousSongs[(PlayerData.job.name..data.zone)], zoneNum = data.zone } } }
	end
	if currentSong[(PlayerData.job.name..data.zone)] then
		local currentSong = currentSong[(PlayerData.job.name..data.zone)]
		if currentSong.status == "Playing: 🔊" then
			musicMenu[#musicMenu+1] = { icon = "fas fa-pause", header = "Pause Music", txt = "Pause music", params = { isServer = true, event = "qb-djbooth:server:pauseMusic", args = { zoneNum = data.zone } } }
		elseif currentSong.status == "Paused: 🔇" then
			musicMenu[#musicMenu+1] = { icon = "fas fa-play", header = "Resume Music", txt = "Resume music", params = { isServer = true, event = "qb-djbooth:server:resumeMusic", args = { zoneNum = data.zone } } }
		end
		musicMenu[#musicMenu+1] = { icon = "fas fa-volume-off", header = "Volume"..song.volume, txt = "Change volume", params = { event = "qb-djbooth:client:changeVolume", args = { zoneNum = data.zone,  } } }
		musicMenu[#musicMenu+1] = { icon = "fas fa-stop", header = "Stop music", txt = "Turn off the music", params = { isServer = true, event = "qb-djbooth:server:stopMusic", args = { zoneNum = data.zone } } }
	end
	exports["qb-menu"]:openMenu(musicMenu)
end)

RegisterNetEvent("qb-djbooth:client:history", function(data)
	local musicMenu = {}
	musicMenu[#musicMenu+1] = { icon = "fas fa-clock-rotate-left", isMenuHeader = true, header = "<img src=https://cdn-icons-png.flaticon.com/512/1384/1384060.png width=20px></img>&nbsp; DJ Booth", txt = "History - Press to play" }
	musicMenu[#musicMenu+1] = { icon = "fas fa-circle-arrow-left", header = "", txt = "Back", params = { event = "qb-djbooth:client:playMusic", args = { job = data.job, zone = data.zoneNum } } }
	for i = #data.history, 1, -1 do
		musicMenu[#musicMenu+1] = { icon = "https://img.youtube.com/vi/"..string.sub(data.history[i], - 11).."/mqdefault.jpg", header = "", txt = data.history[i], params = { event = "qb-djbooth:client:historyPlay", args = { song = data.history[i], zoneNum = data.zoneNum } } }
	end
	exports["qb-menu"]:openMenu(musicMenu)
end)

RegisterNetEvent('qb-djbooth:client:historyPlay', function(data)
       TriggerServerEvent('qb-djbooth:server:playMusic', data.song, data.zoneNum)
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