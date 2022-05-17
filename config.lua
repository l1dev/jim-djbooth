Config = {
	Debug = false, -- Set to true to show target locations
	Locations = {
		[1] = {
			job = "vanilla", -- Set this to required job role
			enableBooth = true, -- option to disable rather than deleting code
			DefaultVolume = 0.1, -- 0.01 is lowest, 1.0 is max
			radius = 30, -- The radius of the sound from the booth
			coords = vector3(120.0, -1281.72, 29.48), -- Where the booth is located
			playing = false, -- don't touch
		},
	},
}
